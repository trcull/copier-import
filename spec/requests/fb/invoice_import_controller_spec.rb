require 'spec_helper'

describe Fb::InvoiceImportController do
  login_integration
  before do 
      @api = double('api')
      @api.stub(:get_taxes).and_return [{'name'=>'VAT','rate'=>6.66},{'name'=>'GST','rate'=>7.77}]
      Fb::RfApi.stub(:new).and_return @api
      @api.stub(:do_request).and_raise "Unexpected network call"
      Fb::RfApi.stub(:has_authorized?).and_return true
      site = create(:site, :key=>'fb')
      create(:site_account, :user=>@user, :site=>site)
      Fb::CreateXeroxInvoicesJob.stub(:cache).and_return 'cachekey'
  end
  
  def do_upload(filename) 
    # for xls: application/vnd.ms-excel
    # for xlsx: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    # create featureviz/tmp directory if it doesn't already exist
    Dir.mkdir('tmp') unless Dir.exist?('tmp')
    post '/fb/invoice_import/xerox_upload' , {:export_file => Rack::Test::UploadedFile.new("spec/fixtures/csv/#{filename}","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")}
  end
  
  describe "xerox" do
    it "does not explode" do
      get '/fb/xerox_invoice'    
    end
  end
  
  describe "sales_by_date" do
    before do
      @invoice = create(:billing_invoice, :site_account=>@user.account_for('fb'))
      @site_account = @invoice.site_account
      @invoice.line_items << create(:billing_line_item, :billing_invoice=>@invoice, :sales_tracking_code=>'1', :quantity=>1, :unit_price=> 10.01, :cost_basis=> 9.00)
      @invoice.line_items << create(:billing_line_item, :billing_invoice=>@invoice, :sales_tracking_code=>'1', :quantity=>1, :unit_price=> 10.01, :cost_basis=> 9.00)
      @start_date = @invoice.created_at.strftime("%Y-%m-%d")
      @end_date = (@invoice.created_at + 1.day).strftime("%Y-%m-%d")
    end
    
    it "returns an appropriately formatted time series" do
      get "/fb/invoice_import/sales_by_date.json?from_date=#{@start_date}&to_date=#{@end_date}"
      response.body.should match(/\"label\":\"1\",\"data\":\[\[\"\d\d\d\d-\d\d\",20.02,2.02\]\]/) #NOTE that both line items should be rolled up into one
    end
    
    it "returns two different time series if there are two sales tracking codes" do
      @invoice.line_items << create(:billing_line_item, :billing_invoice=>@invoice, :sales_tracking_code=>'2')
      get "/fb/invoice_import/sales_by_date.json?from_date=#{@start_date}&to_date=#{@end_date}"
      response.body.should match /\"label\":\"1\"/
      response.body.should match /\"label\":\"2\"/
    
    end
    
    it "returns properly formatted CSV data when asked" do
      @invoice.line_items << create(:billing_line_item, :billing_invoice=>@invoice, :sales_tracking_code=>'2')
      get "/fb/invoice_import/sales_by_date.csv?from_date=#{@start_date}&to_date=#{@end_date}"
      response.body.should match /1,\d\d\d\d-\d\d,\d+\.\d*/
      response.body.should match /2,\d\d\d\d-\d\d,\d+\.\d*/
    end
    
    it "shows only this user's data, not everybody's" do
      other_site_account = create(:site_account)
      other_invoice = create(:billing_invoice)
      other_invoice.line_items << create(:billing_line_item, :billing_invoice=>other_invoice, :sales_tracking_code=>'other')
      get "/fb/invoice_import/sales_by_date.csv?from_date=#{@start_date}&to_date=#{@end_date}"
      response.body.should_not match /other/
    end
    
  end
  
  describe "edit copier" do
    before do
      @copier = create(:xerox_copier)
    end
    
    it "does not explode" do
      get "/fb/invoice_import/copier/#{@copier.id}/edit"  
    end

    it "saves changes" do
      post "/fb/invoice_import/copier/#{@copier.id}", 'copier'=>{'mono_base'=>999}
      updated = Fb::XeroxCopier.find(@copier.id)
      updated.mono_base.should eq 999  
    end

  end
  
  describe "delete copier" do
    before do
      @copier = create(:xerox_copier)
    end
    
    it "does not explode" do
      delete "/fb/invoice_import/copier/#{@copier.id}"
      expect {Fb::XeroxCopier.find(@copier.id)}.to raise_error(ActiveRecord::RecordNotFound)  
    end
  end


  describe "xerox_upload" do 
    before do
      Fb::CreateXeroxInvoicesJob.stub(:enqueue)
      
    end

    it "can handle blank rows at the beginning of the spreadsheet" do
      do_upload '2012DEC_XMPS_Billing.xlsx'
      assigns(:rows_by_serial_number).length.should eq 2 
      assigns(:missing_serial_numbers).length.should eq 2 
    end
    
    it "can handle the older excel file format" do
      do_upload 'invoice_import_controller_spec.xls'
      assigns(:rows_by_serial_number).length.should eq 2
    end

    it "can handle the newer excel file format" do
      do_upload 'invoice_import_controller_spec.xlsx'
      assigns(:rows_by_serial_number).length.should eq 2
    end

    it "skips blank lines in the uploaded spreadsheet" do
      do_upload 'invoice_import_controller_spec.xlsx' #this spreadsheet has a blank line 
      assigns(:rows_by_serial_number).length.should eq 2
    end

    context "not all copiers are set up" do
      it "does not enqueue a job" do
        Fb::CreateXeroxInvoicesJob.should_not_receive(:enqueue)
        do_upload 'invoice_import_controller_spec.xlsx'
      end


      it "fetches clients" do
        do_upload 'invoice_import_controller_spec.xlsx'
        assigns(:clients).should_not be_nil
      end
      
      it "sets missing serial numbers" do
        do_upload 'invoice_import_controller_spec.xlsx'
        assigns(:missing_serial_numbers).length.should eq 2
      end
    end
    
    context "all copiers are set up" do
      before do 
        create(:xerox_copier,:user=>@user, :serial_number=>'XDC342839')
        create(:xerox_copier, :user=>@user,:serial_number=>'XLT277689')
      end

      it "does not enqueue a job" do
        Fb::CreateXeroxInvoicesJob.should_not_receive(:enqueue)
        do_upload 'invoice_import_controller_spec.xlsx'
      end

      it "pulls the right info out of the right columns" do
        do_upload 'invoice_import_controller_spec.xlsx'
        rows = assigns(:sheet_arr)
        columns = Fb::CreateXeroxInvoicesJob.find_columns(rows[0])
        rows[1][columns[:serial_num]].should eq 'XDC342839'
        rows[1][columns[:make]].should eq 'Xerox'
        rows[1][columns[:model]].should eq '7120'
        rows[1][columns[:mono_usage]].should eq 392
        rows[1][columns[:color_usage]].should eq 2424
        rows[1][columns[:mono_color_usage]].should eq 0
        rows[1][columns[:color_level_2_usage]].should eq 0
        rows[1][columns[:color_level_3_usage]].should eq 0
        
      end
      
      it "sets missing serial numbers" do
        do_upload 'invoice_import_controller_spec.xlsx'
        assigns(:missing_serial_numbers).length.should eq 0
      end
      
    end

    it "caches the rows" do
      Fb::CreateXeroxInvoicesJob.should_receive(:cache) do |rows, user|
        rows.length.should eq 3
        rows[0].length.should be > 0
        user.should_not be_nil
      end
      do_upload 'invoice_import_controller_spec.xlsx'
    end

    
  end
  
  describe "add_copier" do
    it "does not explode" do
      attrs = {
        :serial_number=>'fake',
        :make=>'stuff',
        :model=>'stuff',
        :grouping=>'stuff',
        :mono_base=>2,
        :mono_overage=>1.1,
        :color_0_base=>2,
        :color_0_overage=>1.1,
        :mono_color_1_base=>2,
        :mono_color_1_overage=>1.1,
        :color_level_2_base=>2,
        :color_level_2_overage=>1.1,
        :color_level_3_base=>2,
        :color_level_3_overage=>1.1}
      client = create(:fb_client)
      expect {post '/fb/invoice_import/add_copier',{:copier=>attrs, :client_id=>client.id}}.to change {Fb::XeroxCopier.count}.from(0).to(1) 
    end

    it "sets the tax rate based on the tax name" do
      attrs = {
        :serial_number=>'fake',
        :make=>'stuff',
        :model=>'stuff',
        :grouping=>'stuff',
        :mono_base=>2,
        :mono_overage=>1.1,
        :color_0_base=>2,
        :color_0_overage=>1.1,
        :mono_color_1_base=>2,
        :mono_color_1_overage=>1.1,
        :color_level_2_base=>2,
        :color_level_2_overage=>1.1,
        :color_level_3_base=>2,
        :color_level_3_overage=>1.1,
        :tax_name=>'VAT'}
      client = create(:fb_client)
      post '/fb/invoice_import/add_copier',{:copier=>attrs, :client_id=>client.id}
      created = Fb::XeroxCopier.first
      created.tax_name.should eq 'VAT'
      created.tax_rate.should eq 6.66 
    end

  end
  
  describe 'save_copier' do  
    it "sets the tax rate based on the tax name" do
      copier = create(:xerox_copier, :tax_name=>nil, :tax_rate=>nil)
      attrs = {
        :tax_name=>'VAT'}
      post "/fb/invoice_import/copier/#{copier.id}",{:copier=>attrs}
      created = Fb::XeroxCopier.find(copier.id)
      created.tax_name.should eq 'VAT'
      created.tax_rate.should eq 6.66 
    end

  end

end

