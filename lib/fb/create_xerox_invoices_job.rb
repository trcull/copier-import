class Fb::CreateXeroxInvoicesJob 
  CACHE_KEY_CSV = 'CreateXeroxInvoicesJob.CSV'

  def to_map_by(key, an_array)
    rv = {}
    an_array.each do |elem|
    rv[elem[key]] = elem
    end
    return rv
  end
    
  def info(msg)
    Rails.logger.info msg
  end
  
  def self.cache(rows, user)
    key = cache_key(user)
    Rails.logger.info "Caching spreadsheet rows for user #{user.id} under key #{key} length #{rows.length}"
    Infrastructure::DocStore.add_or_update key, rows.to_json
    key
  end
  
  def self.enqueue(key, user)
    Fb::CreateXeroxInvoicesJob.new.delay(priority: PRIORITY_INTERACTIVE).perform(key, user.id)
  end
  
  def self.cache_key(user)
    key = "cache/#{CACHE_KEY_CSV}.#{user.id}.#{Time.now.to_f}"    
  end
  
  def perform(key, user_id)
    Rails.logger.info "[NOTIFY] CREATING XEROX INVOICES FOR #{key} and user #{user_id}"
    begin
      rows_json = Infrastructure::DocStore.get_value(key)
      if rows_json.nil?
        raise "Could not find cached spreadsheet rows for user id #{user_id} with key #{key}"
      else
        rows = JSON.parse(rows_json, {:symbolize_names => true})
      end
      do_perform(rows, user_id)
    rescue => e
      msg = "Sorry, there was an error trying to send your invoices to Freshbooks.  Please try again later.  "
      Rails.logger.error(msg + e.message)
      Infrastructure::Alerting.raise_alert(user_id, Infrastructure::Alerting::SOURCE_XEROX, Infrastructure::Alerting::LEVEL_WARN, msg)
    end   
    Rails.logger.info "[NOTIFY] DONE CREATING XEROX INVOICES FOR #{key} and user #{user_id}"
  end
  
  def self.find_header_row(rows)
    rows[0]
  end
  
  def do_perform(rows, user_id)
    Rails.logger.info("Creating Xerox invoices for user id #{user_id} with this many rows: #{rows.length}")
    user = User.find(user_id)
    columns = Fb::CreateXeroxInvoicesJob.find_columns(Fb::CreateXeroxInvoicesJob.find_header_row(rows))
    line_items_by_client = Hash.new {|hash, key| hash[key] = []}
    sub_totals_by_client_by_grouping = Hash.new {|hash, key| hash[key] = Hash.new{|hash2, key2| hash2[key2]=0}}
    color_types = [
      ["B/W",:mono_start, :mono_end, :mono_usage,:mono_base,:mono_overage],
      ["Color",:color_start, :color_end, :color_usage,:color_0_base,:color_0_overage],
      ["Mono/Color",:mono_color_start, :mono_color_end, :mono_color_usage,:mono_color_1_base,:mono_color_1_overage],
      ["Color 2",:color_level_2_start, :color_level_2_end, :color_level_2_usage,:color_level_2_base,:color_level_2_overage],
      ["Color 3",:color_level_3_start, :color_level_3_end, :color_level_3_usage,:color_level_3_base,:color_level_3_overage]
    ]
    i = 0
    rows.each do |row|
      #assume there's a header row and skip it
      if i > 0
        serial_num = row[columns[:serial_num]]
        copier = Fb::XeroxCopier.where(:serial_number=>serial_num, :user_id=>user_id).first
        if copier.nil?
          Rails.logger.warn("missing copier with serial number #{serial_num} for user #{user_id}")
          msg = "Missing copier with serial number #{serial_num}"
          Infrastructure::Alerting.raise_alert(user_id, Infrastructure::Alerting::SOURCE_XEROX, Infrastructure::Alerting::LEVEL_WARN, msg)
        else
          tax_rate = 0
          if copier.tax_name.present? && copier.tax_name != ""
            if copier.tax_rate.present?
              tax_rate = copier.tax_rate/100.0            
            else
              msg = "Copier #{copier.serial_number} has a tax listed of #{copier.tax_name} but no tax rate: #{copier.tax_rate}"
              Rails.logger.error msg
              Infrastructure::Alerting.raise_alert(user_id, Infrastructure::Alerting::SOURCE_XEROX, Infrastructure::Alerting::LEVEL_WARN, msg)
            end
          end
          grouping = row[columns[:city]]
          grouping = copier.grouping if (copier.grouping && copier.grouping.length > 0)
          grouping = "Copies" if grouping.nil?
          #eliminate the included counts that are zero and put together a description of rest of the included base counts
          base_counts = color_types.reject{|e| copier.send(e[4]) <= 0}.collect {|t|  "#{copier.send(t[4])} #{t[0]}"}.join(", ")
          client_id = copier.fb_client.fb_id
          line_items_by_client[client_id].push({
            :name=>grouping,
            :description => "#{row[columns[:make]]} #{row[columns[:model]]} #{serial_num} Monthly Base, includes: #{base_counts}",
            :qty => 1,
            :unit_price => copier.base_rate,
                :tax_name => copier.tax_name,
                :tax_rate => copier.tax_rate,
                :copier=> copier,
                :secondary_sort=>0, 
                :cost_basis=>row[columns[:cost_basis]]
          } )
          sub_totals_by_client_by_grouping[client_id][grouping] = sub_totals_by_client_by_grouping[client_id][grouping] + copier.base_rate + (copier.base_rate * tax_rate)
          color_types.each_with_index do |color_type, index|
            qty = (row[columns[color_type[3]]] - copier.send(color_type[4])).to_i
            qty = qty < 0 ? 0 : qty
            included_qty = copier.send(color_type[4])
            if qty > 0 || included_qty > 0
              color_desc = color_type[0]
              start = color_type[1]
              finish = color_type[2]
              price_method = color_type[5]
              price = copier.send(price_method)
              if price <= 0
                msg = "The overage price for copier #{serial_num} and copy type #{color_desc} is zero, but the customer actually used #{qty} of that type."
                Infrastructure::Alerting.raise_alert(user_id, Infrastructure::Alerting::SOURCE_XEROX, Infrastructure::Alerting::LEVEL_WARN, msg)
              end
              
              sub_totals_by_client_by_grouping[client_id][grouping] = sub_totals_by_client_by_grouping[client_id][grouping] + (qty*price) + (qty*price*tax_rate) 
              line_items_by_client[copier.fb_client.fb_id].push({
                :name=>grouping,
                :description => "#{row[columns[:make]]} #{row[columns[:model]]} #{serial_num} #{color_desc} (#{row[columns[start]].to_i} to #{row[columns[finish]].to_i})",
                :qty => qty,
                :unit_price => price,
                :tax_name => copier.tax_name,
                :tax_rate => copier.tax_rate,
                :secondary_sort=> (index+1), 
                :copier=>copier,
                :cost_basis=>0
              } )
            end
          end
        end
      end
      i = i + 1
    end
    site_account = user.account_for('fb')
    line_items_by_client.each_pair do |fb_client_id, line_items|
      subtotals = sub_totals_by_client_by_grouping[fb_client_id]
      notes = "Subtotals:\n" 
      subtotals.each_pair do |grouping, total|
        notes = notes + "\t#{grouping}: #{'%.2f' % total}\n"
      end
      line_items = line_items.sort_by {|a| [a[:name].downcase, a[:copier].serial_number, a[:secondary_sort]]}
      #line_items.sort! {|a,b| a[:name].downcase <=> b[:name].downcase}
      save_line_items site_account, fb_client_id, line_items
      create_invoice site_account, fb_client_id, line_items , notes
    end
    
  end
    
  def save_line_items(site_account, fb_client_id, line_items)
    invoice = Billing::Invoice.new(:billing_client_id=>fb_client_id)
    invoice.site_account = site_account
    line_items.each do |line|
      item = Billing::LineItem.new
      item.name = line[:name]
      item.description = line[:description]
      item.unit_price = line[:unit_price]
      item.quantity = line[:qty]
      item.item_id = line[:copier].serial_number
      item.sales_tracking_code = line[:copier].sales_tracking_code
      item.cost_basis = line[:cost_basis] || 0
      invoice.line_items << item
    end
    invoice.save!
    
  end
  
  
  def create_invoice(site_account, fb_client_id, line_items, notes)
    Rails.logger.info("creating invoice for user #{site_account.user.id} and client #{fb_client_id} with #{line_items.length} line_items")
    api = Fb::RfApi.new(site_account)
    api.create_invoice fb_client_id, line_items, notes
  end


  def self.find_columns(header_row)
    columns = {:make => 2,
    :model => 3,
    :serial_num => 4,
    :mono_start => 16,
    :mono_end => 17,
    :mono_usage => 19,
    :color_start => 22,
    :color_end => 23,
    :color_usage => 25,
    :mono_color_start => 28,
    :mono_color_end => 29,
    :mono_color_usage => 31,
    :color_level_2_start => 34,
    :color_level_2_end => 35,
    :color_level_2_usage => 37,
    :color_level_3_start => 40,
    :color_level_3_end => 41,
    :color_level_3_usage => 43,
    :city=>60,
    :cost_basis=>56}
    
    i = 0
    header_row.each do |column|
      case column 
      when "Make" 
        columns[:make] = i
      when "Model" 
        columns[:model] = i
      when "Serial #" 
        columns[:serial_num] = i
      when "Mono-Beg" 
        columns[:mono_start] = i
      when "Mono-End" 
        columns[:mono_end] = i
      when "Mono-Usage"
        columns[:mono_usage] = i
      when "Color-Beg"
        columns[:color_start] = i
      when "Color-End"
        columns[:color_end] = i
      when "Color-Usage"
        columns[:color_usage] = i
      when "MonoColor1-Beg"
        columns[:mono_color_start] = i
      when "MonoColor1-End"
        columns[:mono_color_end] = i
      when "MonoColor1-Usage"
        columns[:mono_color_usage] = i
      when "ColorLevel2-Beg"
        columns[:color_level_2_start] = i
      when "ColorLevel2-End"
        columns[:color_level_2_end] = i
      when "ColorLevel2-Usage"
        columns[:color_level_2_usage] = i
      when "ColorLevel3-Beg"
        columns[:color_level_3_start] = i
      when "ColorLevel3-End"
        columns[:color_level_3_end] = i
      when "ColorLevel3-Usage"
        columns[:color_level_3_usage] = i
      when "City"
        columns[:city] = i
      when "Device Total"
        columns[:cost_basis] = i
      end
      i = i + 1
    end
    columns
  end
  

end
