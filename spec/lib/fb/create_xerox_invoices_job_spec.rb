require 'spec_helper'

describe Fb::CreateXeroxInvoicesJob do
  before do
    Alert.stub(:create).and_raise("this alert was unexpected.  if you really expected it, then change your test to expect it with a should_receive like so: Infrastructure::Alerting.should_receive(:raise_alert)")
    @fb_client = create(:fb_client)
    site = Site.where(:key=>Site::FRESHBOOKS).first
    @site_account = create(:site_account, :site=>site)
    @user = @site_account.user
    @copier = Fb::XeroxCopier.new(:serial_number=>'XDC342839',
                                 :make=>'a make',
                                 :model=>'a model',
                                 :grouping=>'a grouping',
                                 :mono_base=>100,
                                 :mono_overage=>0.014,
                                 :color_0_base=>100,
                                 :color_0_overage=>0.014,
                                 :mono_color_1_base=>100,
                                 :mono_color_1_overage=>0.014,
                                 :color_level_2_base=>0,
                                 :color_level_2_overage=>0.014,
                                 :color_level_3_base=>0,
                                 :color_level_3_overage=>0.014,
                                 :base_rate=>12.22,
                                 :tax_name=>'VAT',
                                 :tax_rate=>6.45,
                                 :sales_tracking_code=>'default'
                                 )
    @copier.fb_client = @fb_client
    @copier.user = @user
    @copier.save!
    @copier = Fb::XeroxCopier.find(@copier.id)
    @rows = [
      ["Invoice #","Customer","Make","Model","Serial #",
        "Mono-Beg","Mono-End","Mono-Usage",
        "Color-Beg","Color-End","Color-Usage",
        "MonoColor1-Beg","MonoColor1-End","MonoColor1-Usage",
        "ColorLevel2-Beg","ColorLevel2-End","ColorLevel2-Usage",
        "ColorLevel3-Beg","ColorLevel3-End","ColorLevel3-Usage","Device Total"
        ],
      ["2204263444","A","Xerox","7120","XDC342839",
        4955,5347,392,
        21859,24283,2424,
        111,111,0,
        0,0,0,
        0,0,0,94.34
        ]
    ]
                                 
  end

  it "creates one invoice when there is one line" do
    subject.should_receive(:create_invoice) do |site_account, fb_client_id, line_items, notes|
      site_account.user.id.should eq @user.id
      fb_client_id.should eq @fb_client.fb_id
      line_items.length.should eq 4 #one line for mono, one for color, one for mono/color, one for the base charge
      line_items[0][:description].should eq "Xerox 7120 XDC342839 Monthly Base, includes: 100 B/W, 100 Color, 100 Mono/Color"
      line_items[0][:qty].should eq 1
      line_items[0][:unit_price].should eq @copier.base_rate
      line_items[0][:name].should eq 'a grouping'
      line_items[0][:tax_name].should eq @copier.tax_name
      line_items[0][:tax_rate].should eq @copier.tax_rate
      line_items[1][:description].should eq "Xerox 7120 XDC342839 B/W (4955 to 5347)"
      line_items[1][:qty].should eq 292 #392 minus the included 100 in mono base
      line_items[1][:unit_price].should eq @copier.mono_overage
      line_items[1][:name].should eq 'a grouping'
      line_items[1][:tax_name].should eq @copier.tax_name
      line_items[1][:tax_rate].should eq @copier.tax_rate
      line_items[2][:description].should eq "Xerox 7120 XDC342839 Color (21859 to 24283)"
      line_items[2][:qty].should eq 2324 #2424 minus the included 100 in color base
      line_items[2][:unit_price].should eq @copier.color_0_overage
      line_items[2][:name].should eq 'a grouping'
      line_items[2][:tax_name].should eq @copier.tax_name
      line_items[2][:tax_rate].should eq @copier.tax_rate
      line_items[3][:description].should eq "Xerox 7120 XDC342839 Mono/Color (111 to 111)"
      line_items[3][:qty].should eq 0 #there wasn't any usage
      line_items[3][:unit_price].should eq @copier.mono_color_1_overage
      line_items[3][:name].should eq 'a grouping'
      line_items[3][:tax_name].should eq @copier.tax_name
      line_items[3][:tax_rate].should eq @copier.tax_rate
    end
    
    subject.do_perform(@rows, @user.id)
  end

  it "assigns the cost basis to the base monthly charge" do
    subject.should_receive(:create_invoice) do |site_account, fb_client_id, line_items, notes|
      line_items.length.should eq 4 #one line for mono, one for color, one for mono/color, one for the base charge
      line_items[0][:description].should eq "Xerox 7120 XDC342839 Monthly Base, includes: 100 B/W, 100 Color, 100 Mono/Color"
      line_items[0][:cost_basis].should eq 94.34
      line_items[1][:description].should eq "Xerox 7120 XDC342839 B/W (4955 to 5347)"
      line_items[1][:cost_basis].should eq 0
      line_items[2][:description].should eq "Xerox 7120 XDC342839 Color (21859 to 24283)"
      line_items[2][:cost_basis].should eq 0
      line_items[3][:description].should eq "Xerox 7120 XDC342839 Mono/Color (111 to 111)"
      line_items[3][:cost_basis].should eq 0
    end
    
    subject.do_perform(@rows, @user.id)
  end


  it "subtotals everything in the notes field" do
    subject.should_receive(:create_invoice) do |site_account, fb_client_id, line_items, notes|
      notes.should eq "Subtotals:\n\ta grouping: 51.99\n" # should be 48.84 for the copies plus the 6.45% tax rate, rounded to the nearest cent = 51.99
    end
    subject.do_perform(@rows, @user.id)
  end


  it "only shows base counts when they are greater than zero" do
    @copier.mono_color_1_base = 0
    @copier.save!
    subject.should_receive(:create_invoice) do |site_account, fb_client_id, line_items|
      line_items[0][:description].should_not match(/0 Mono\/Color/)
    end
    
    subject.do_perform(@rows, @user.id)
  end

  it "sends an alert if there are copies for a color type that has a zero unit price" do
    @copier.mono_overage = 0
    @copier.save!
    subject.stub(:create_invoice)
    Infrastructure::Alerting.should_receive(:raise_alert)
    subject.do_perform(@rows, @user.id)
  end

  it "saves invoices to the database for later reporting" do
    subject.stub(:create_invoice)
    expect {subject.do_perform(@rows, @user.id)}.to change{Billing::Invoice.count}.from(0).to(1)
  end
  
  it "saves the right number of line items with the right data" do
    subject.stub(:create_invoice)
    subject.do_perform(@rows, @user.id)
    invoice = Billing::Invoice.first
    invoice.line_items.count.should eq 4 #one for base rate, one for each copy type
    line = invoice.line_items[0]
    line.name.should eq "a grouping"
    line.description.should match /XDC342839/ 
    line.unit_price.should eq @copier.base_rate
    line.quantity.should eq 1
    line.item_id.should eq "XDC342839"
    line.cost_basis.should eq 94.34
  end
  
  it "saves the sales tracking code from the matching copier" do
    subject.stub(:create_invoice)
    subject.do_perform(@rows, @user.id)
    line = Billing::Invoice.first.line_items[0]
    line.sales_tracking_code.should eq @copier.sales_tracking_code
  end
  

  context "there are two copiers" do
    before do
      @copier2 = Fb::XeroxCopier.new(:serial_number=>'xxx111',
                                   :make=>'a make',
                                   :model=>'a model',
                                   :grouping=>'1zzz',
                                   :mono_base=>100,
                                   :mono_overage=>0.014,
                                   :color_0_base=>100,
                                   :color_0_overage=>0.014,
                                   :mono_color_1_base=>100,
                                   :mono_color_1_overage=>0.014,
                                   :color_level_2_base=>100,
                                   :color_level_2_overage=>0.014,
                                   :color_level_3_base=>100,
                                   :color_level_3_overage=>0.014,
                                   :tax_name=>nil,
                                   :tax_rate=>nil
                                   )

      @copier2.user = @user
      @copier2.fb_client = @fb_client #note: this must be the same client
      @copier2.save!
      @rows.push ["2204263444","A","Xerox","WWWYYY","xxx111",
          4955,5347,392,
          21859,24283,2424,
          1,1000,1000,
          1,1000,1000,
          1,1000,1000
          ]
    end      
  
    it "creates two invoices when there are two lines for different clients" do
      @copier2.fb_client = create(:fb_client) #note: this must be a different client
      @copier2.save!
      subject.should_receive(:create_invoice).twice
      subject.do_perform(@rows, @user.id)
    end
  
    it "creates one invoice when there are two lines for the same client" do
      @copier2.fb_client = @fb_client #note: this must be the same client
      @copier2.save!
      subject.should_receive(:create_invoice).once
      subject.do_perform(@rows, @user.id)
    end

    it "orders the base amounts before the overage amounts" do
      subject.should_receive(:create_invoice) do |site_account, fb_client_id, line_items|
        line_items[0][:description].should match(/Monthly Base/)
        line_items[6][:description].should match(/Monthly Base/)
      end
      
      subject.do_perform(@rows, @user.id)
    end
  end

  it "finds non-default column positions" do
    columns = Fb::CreateXeroxInvoicesJob.find_columns(["foo","bar","MonoColor1-Beg"])
    columns[:mono_color_start].should eq 2
  end

  it "finds default column positions" do
    columns = Fb::CreateXeroxInvoicesJob.find_columns(["foo","bar"])
    columns[:mono_color_start].should eq 28
  end

end
