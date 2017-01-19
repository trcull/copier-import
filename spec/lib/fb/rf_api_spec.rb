require 'spec_helper'
describe Fb::RfApi do #
  subject do
    @site_account = create(:site_account)
    @site_account.field1 = "featureviz"
    @site_account.token = "DTYxJVitZgTKm6N6tQWxW6KYvu2npVSJY"
    @site_account.secret = "w98ENbXkvNwZfzucGTY2WeWvwFc6Ea9ju"
    Fb::RfApi.new_instance(@site_account)
  end
  before do
    @integration_client_id = 3 # the INTEGRATION_TEST Client
    @integration_project_id = 2
    @integration_staff_id = 1
  end
  
  describe "making fake HTTP calls" do
  end
  
  describe "in a test bed" do

    
  end
  
  describe "making real HTTP calls" , :integration => true do
    it "can create a callback request" do
      rv = subject.create_callback("estimate.create", "http://testurl/ok/to/remove")
    end

    it "can delete a callback request" do
      rv = subject.create_callback("estimate.update", "http://testurl/ok/to/remove1")
      subject.delete_callback(rv["callback_id"])
    end

    
    it "can create an invoice" do
      lines = [{:description=>'my description',
            :unit_price=>1.44,
            :qty=>122,
            :tax_name=>'VAT',
            :tax_rate=>6}]
      rv = subject.create_invoice(@integration_client_id,lines)
    end
    
    it "can create an invoice" do
      lines = [{:description=>'my description',
            :unit_price=>1.44,
            :qty=>122,
            :tax_name=>'VAT',
            :tax_rate=>6}]
      rv = subject.create_invoice(@integration_client_id,lines)
    end

    it "returns a list of taxes" do
      taxes = subject.get_taxes()
      taxes.length.should eq 2
      taxes[0]['name'].should eq 'GST'
      taxes[0]['rate'].should eq '6'
      taxes[1]['name'].should eq 'VAT'
    end

  it "can connect to freshbooks without throwing an exception" do
    conn = subject.fb_connection
    conn.project.list
  end

    it "returns an oauth access token" do
        # req_token = subject.oauth_request_token
        # #pretend like the user logged in
        # response = subject.send(:post,"https://featureviz.freshbooks.com/oauth/oauth_authorize.php", {:oauth_token=>req_token.token,:user=>'featureviz-fb',:pass=>'fb4featureviz',:submit=>'true'})
        # location = response['location'].scan(/oauth_verifier=(\d*\w*)/)
        # oauth_verifier = location[0][0]
        # access_token = subject.oauth_access_token(req_token, oauth_verifier)
        # access_token.token.should_not be_nil
        # access_token.secret.should_not be_nil
    end

    it "returns an oauth request token" do
      # token = subject.oauth_request_token
      # token.token.should_not be_nil
      # token.secret.should_not be_nil
    end

  describe "clients with one additional contact" do
    it "returns contacts array" do
      client = subject.fb_client(@integration_client_id);
      contacts = [client["contacts"]["contact"]].flatten(1)
      contacts.class.should eq Array
      contacts.length.should eq 1
    end
  end
  
  describe "invoices" do
    it "returns invoices for sent status" do
      
      invoices = subject.fb_invoices("unpaid")
      invoices.length.should >= 1
      client_ids = clients = invoices.collect {|elem| elem['client_id']}
      client_ids.should include @integration_client_id.to_s()
    end

    it "invoice of primary has contact id" do
      #invoice with primary contact
      invoice = subject.fb_invoice("126368")
      invoice["contacts"]["contact"].class.should == Array
      invoice["contacts"]["contact"].length.should eq 1
      invoice["contacts"]["contact"][0]["contact_id"].should eq "0"
      
    end

    it "invoice of secondary has contact id" do
      #invoice with secondary contact
      invoice = subject.fb_invoice("126389")

      invoice["contacts"]["contact"].class.should == Array
      invoice["contacts"]["contact"].length.should eq 1

      invoice["contacts"]["contact"][0]["contact_id"].should eq "2"
      
    end

    it "invoice has multiple contacts" do
      #invoice with secondary contact
      invoice = subject.fb_invoice("127712")
      invoice["contacts"]["contact"].class.should == Array
      invoice["contacts"]["contact"].length.should eq 2
    end

    
  end
  
  describe "projects" do
    it "returns all the tasks for a project" do
      tasks = subject.fb_tasks_by_project(@integration_project_id)
      tasks.length.should eq 2
      names = tasks.collect {|elem| elem['name']}
      names.should include "General"
      names.should include "Meetings"
    end
    
    it "returns all time entries for a project" do
      entries = subject.fb_time_by_project(@integration_project_id)
      entries.length.should eq 4 
    end
    
    it "returns many projects" do
      projects = subject.fb_projects
      projects.length.should be > 1 # return multiples
      projects[0]['project_id'].should_not be_nil
      projects[0]['name'].should_not be_nil
    end
  end
  
  describe "expenses" do
    it "returns expenses" do
      expenses = subject.fb_expenses
      expenses.length.should be > 1 # return multiples
      expenses[0]['amount'].to_f.should be > 0 
    end
    
    it "returns expenses for a project" do
      expenses = subject.fb_expenses_by_project(@integration_project_id) #14 is the Presynct San Bernardino Implementation
      expenses.length.should eq 2 # the project is over, so there should be 4 expenses for all time
      expenses[0]['amount'].to_f.should eq 10.00
      expenses[0]['project_id'].should eq @integration_project_id.to_s
      expenses[0]['client_id'].should eq @integration_client_id.to_s
      
    end
  end
  
  describe "invoices" do
    it "returns invoices by date range" do
      payments = subject.fb_payments_by_date_range('2012-06-01','2012-06-30')
      payments.length.should eq 3
    end
  end
  
  describe "staff" do
    it "lists at least one staffer" do
      staff = subject.fb_staff
      staff.length.should be > 0
      staff[0]['staff_id'].should_not be_nil
      staff[0]['username'].should_not be_nil
    end
    
    it "returns staffers by id" do
      staffer = subject.fb_staffer_by_id(@integration_staff_id)
      staffer['username'].should eq "featureviz-fb"
    end
  end
  end  
end
