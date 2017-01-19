#requiring because of this: https://github.com/hmcgowan/roo/issues/13
#require 'iconv'

class Fb::InvoiceImportController < Fb::FbController
  
  def set_title
    @title = "FreshBooks: Invoice Import"
  end
  
  def xerox_invoice
    @user = current_user
    @clients = fetch_clients
    @copiers = Fb::XeroxCopier.where(:user_id=>@user.id).order(:serial_number)
  end

  def fetch_clients
    Fb::FbClient.where(:user_id=>current_user.id).order(:name)  
  end
  
  def sales_by_date
    start_date = params[:from_date].nil? ? (DateTime.now - 15.days) : params[:from_date]
    end_date = params[:to_date].nil? ? DateTime.now : params[:to_date]
    site_accounts = current_user.site_accounts.collect{|i|i.id}
    @invoices = Billing::Invoice.includes(:line_items).where(:created_at => (start_date..end_date)).where(:site_account_id=>site_accounts)
    line_items_by_month_and_tracking_code = Hash.new {|by_month, month| by_month[month] = Hash.new {|by_code, code| by_code[code] = []}}
    copiers_by_serial_number = Hash.new
    copiers_to_find = []
    @invoices.each do |invoice|
      invoice.line_items.each do |line| 
        line_items_by_month_and_tracking_code[invoice.created_at.strftime("%Y-%m")][line.sales_tracking_code] << line
        copiers_to_find.push(line.item_id) if !copiers_to_find.any?{|e| e == line.item_id}
      end
    end
    Fb::XeroxCopier.where(:serial_number=>copiers_to_find).each {|copier| copiers_by_serial_number[copier.serial_number] = copier }
    
    data_by_tracking_code = Hash.new {|hash, key| hash[key] = {:label=>key, :data=>[]}}
    line_items_by_month_and_tracking_code.each_pair do |month, by_tracking_code|
      by_tracking_code.each_pair do |tracking_code, lines|
        total_value = lines.reduce(0){|sum, line|sum + (line.unit_price * line.quantity)}
        total_profit = lines.reduce(0) do |sum, line|
          if line.cost_basis && line.unit_price && line.quantity
            copier = copiers_by_serial_number[line.item_id]
            sum + ((line.unit_price * line.quantity) - line.cost_basis)
          else
            sum
          end
        end
        data_by_tracking_code[tracking_code][:data] << [month, total_value.round(2), total_profit.round(2)]
      end
    end
    
    @results = []
    data_by_tracking_code.each_key do |key|
      series = data_by_tracking_code[key]
      series[:data].sort!{|a, b| DateTime.strptime(a[0],"%Y-%m") <=> DateTime.strptime(b[0],"%Y-%m")}
      @results << series
    end
    
    respond_to do |format|
      format.json { render :json=>@results.to_json }
      format.csv { render 'sales_by_date' }
    end
  end
  
  def _copier_params
    params.require(:copier).permit([:serial_number,
        :make,
        :model,
        :grouping,
        :mono_base,
        :mono_overage,
        :color_0_base,
        :color_0_overage,
        :mono_color_1_base,
        :mono_color_1_overage,
        :color_level_2_base,
        :color_level_2_overage,
        :color_level_3_base,
        :color_level_3_overage,
        :fb_client_id, 
        :base_rate,
        :tax_name,
        :tax_rate,
        :sales_tracking_code])
  end
  
  def add_copier
    copier = Fb::XeroxCopier.new(_copier_params())
    api = Fb::RfApi.new(current_user.account_for('fb'))
    tax_rates = api.get_taxes
    tax_rates.each do |rate|
      copier.tax_rate = rate['rate'] if rate['name'] == copier.tax_name
    end
    copier.user = current_user
    copier.fb_client = Fb::FbClient.find(params[:client_id])
    copier.save!
    render :json=>copier.to_json
  end
  
  def delete_copier
    copier = Fb::XeroxCopier.find(params[:id])
    copier.destroy
    flash[:notice] = "Copier #{copier.serial_number} deleted"
    redirect_to '/fb/xerox_invoice'
  end
  
  def edit_copier
    @clients = fetch_clients
    @copier = Fb::XeroxCopier.find(params[:id])
    api = Fb::RfApi.new(current_user.account_for('fb'))
    @tax_rates = api.get_taxes
    respond_to do |format|
      format.html
    end
  end
  
  def save_copier
    @copier = Fb::XeroxCopier.find(params[:id])
    api = Fb::RfApi.new(current_user.account_for('fb'))
    tax_rates = api.get_taxes
    @copier.tax_rate = nil
    tax_rates.each do |rate|
      @copier.tax_rate = rate['rate'] if rate['name'] == _copier_params()[:tax_name]
    end
    if @copier.update_attributes(_copier_params())
      flash[:notice] = "Copier #{@copier.serial_number} saved"
      redirect_to '/fb/xerox_invoice'
    else
      respond_to do |format|
        format.html {render :action=>:edit_copier}
      end
    end
  end
  
  def guess_file_type(uploaded_file)
    rv = nil
    file_name = uploaded_file.original_filename
    Rails.logger.info "guessing file type of file #{file_name} and content type #{uploaded_file.content_type}"
    if file_name.match /\.xls$/
      rv = 'xls'
    elsif file_name.match /\.xlsx$/
      rv = 'xlsx'
    else
      Rails.logger.info "couldn't guess based on file name, so guessing based on content type "
      # try to guess based on the mime type
      if uploaded_file.content_type.match /application\/vnd\.ms-excel/
        rv = 'xls'
      elsif uploaded_file.content_type.match /application\/vnd.openxmlformats-officedocument\.spreadsheetml\.sheet/
        rv = 'xlsx'
      end
    end
    #just default if we haven't figured it out.
    rv ||= 'xlsx'
    rv
  end
  
  def try_parse_spreadsheet(extension, working)
    if extension == 'xlsx'
      begin
        # prefixing Excel(x) with Roo:: due to uninitialized constant bug: http://railscasts.com/episodes/396-importing-csv-and-excel?view=comments
        spreadsheet = Roo::Excelx.new working.path
      rescue => e
        Rails.logger.error "Exception parsing excel file #{params[:export_file].original_filename} with exception #{e.message}"
        #try the other one in case we guessed the file format wrong
        spreadsheet = Roo::Excel.new working.path
      end
    else
      begin
        spreadsheet = Roo::Excel.new working.path
      rescue => e
        msg = "Exception parsing excel file #{params[:export_file].original_filename} with exception #{e.message}"
        Rails.logger.error msg
        #try the other one in case we guessed the file format wrong
        spreadsheet = Roo::Excelx.new working.path
      end
    end
    spreadsheet
  end
  
  def find_header_row(spreadsheet, sheet)
    header = 1.upto(spreadsheet.last_row(sheet)) do |row|
      row_arr = spreadsheet.row(row,sheet)
      non_nil_count = 0
      1.upto(row_arr.length) do |column|
        non_nil_count += 1 if !row_arr[column].nil?        
      end
      if non_nil_count > 6
        return row
      end 
    end  
  end
  
  def xerox_upload
    if params[:export_file].nil?
      flash[:error] = "No upload file selected.  Please select an upload file"
      redirect_to '/fb/xerox_invoice'
    else
      uploaded_file = params[:export_file].tempfile
      extension = guess_file_type(params[:export_file])
      working = Tempfile.new(['xerox_upload',".#{extension}"],Rails.root.join('tmp') )
      begin
        working.write params[:export_file].tempfile.read.force_encoding("UTF-8")
        spreadsheet = try_parse_spreadsheet(extension, working)        
        @sheet_arr = []
        @missing_serial_numbers = []
        @rows_by_serial_number = Hash.new
        sheet = spreadsheet.default_sheet
        if spreadsheet.first_row(sheet) # sheet is not empty
          header_index = find_header_row(spreadsheet, sheet)
          @columns = Fb::CreateXeroxInvoicesJob.find_columns(spreadsheet.row(header_index, sheet))
          #start with 2 to skip header row
          (header_index).upto(spreadsheet.last_row(sheet)) do |row|
            row_arr = spreadsheet.row(row, sheet)
            serial_number = row_arr[@columns[:serial_num]]
            #skip any blank rows
            if serial_number.present? && serial_number.length > 0
              @sheet_arr.push row_arr
              if row > header_index
                @missing_serial_numbers.push serial_number 
                @rows_by_serial_number[serial_number] = row_arr
              end
            end
          end # sheet not empty
        end
        existing_serial_numbers = Fb::XeroxCopier.connection.select_values("select serial_number from xerox_copiers where user_id = #{current_user.id}")
        @missing_serial_numbers.reject! {|s| existing_serial_numbers.include? s}
        session[:cache_key] = Fb::CreateXeroxInvoicesJob.cache(@sheet_arr, current_user)
        if @missing_serial_numbers.length > 0
          @clients = fetch_clients
          api = Fb::RfApi.new(current_user.account_for('fb'))
          @tax_rates = api.get_taxes
        else
          @clients = []
          @tax_rates = []
        end
      ensure
        working.unlink
      end    
      respond_to do |format|
        format.html
      end
    end
  end
  
  def xerox_confirm
    Fb::CreateXeroxInvoicesJob.enqueue session[:cache_key], current_user
    flash[:notice] = "Invoices sending in background"
    redirect_to '/fb/xerox_invoice'
  end
  

end
