require 'spec_helper'

describe Mailgun::WebhooksController do
  
  describe "all types" do
    before do 
      @example_post = {"my-custom-data"=>
          "{\"subject\":\"[support] track me\",\"from\":\"Support Messages \\u003Csupport@retentionfactory.com\\u003E\",\"site_account\":99}", 
      "city"=>"Mountain View", 
      "domain"=>"mg.retentionfactory.com", 
      "device-type"=>"desktop", 
      "client-type"=>"browser", 
      "h"=>"103498c4a3ec621597dba96e76a8c90c", 
      "region"=>"CA", 
      "client-name"=>"Firefox", 
      "user-agent"=>"Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (via ggpht.com GoogleImageProxy)", 
      "country"=>"US", 
      "client-os"=>"Windows", 
      "tag"=>"site-account-99", 
      "ip"=>"66.249.82.4", 
      "message-id"=>"20140318000530.19857.89601@mg.retentionfactory.com", 
      "recipient"=>"support@retentionfactory.com", 
      "event"=>"opened", 
      "timestamp"=>"1395101161", 
      "token"=>"9l1qsdrp06pe4wt1nlug8wmajnnd71xt5yoj8jh6ajydo9k0p0", 
      "signature"=>"60fb96d16c0f0b4a3196fb2678ddb1b9913126711b8a47c2c4d28d2391c99e35", 
      "controller"=>"mailgun/webhooks", 
      "action"=>"open"}
    end
 
    it "saves a raw record" do
      post '/mailgun/webhook/open', @example_post
      wh = Mailgun::RawWebhook.last
      wh.mailgun_type.should eq 'opened'
      wh.email.should eq 'support@retentionfactory.com'
      wh.site_account_id.should eq 99
      wh.from.should eq "Support Messages <support@retentionfactory.com>"
      wh.subject.should eq "[support] track me"
    end
    
    context "the customer had been contacted" do
      before do
        @customer_from_this_org = create(:customer, :email=>'support@retentionfactory.com')
        @org = @customer_from_this_org.organization
        @other_customer_from_this_org = create(:customer, :organization=>@org)
        @customer_from_other_org = create(:customer)
        @other_org = @customer_from_other_org.organization

        @category = create(:msg_category)
        @this_org_template = create(:msg_template, :msg_category=>@category, :organization=>@org)
        @sent_at = 1.day.ago
        @this_org_msg_1 = create(:msg, :msg_template=>@this_org_template, :sent_at=>@sent_at)
        @this_org_msg_2 = create(:msg, :msg_template=>@this_org_template, :sent_at=>@sent_at)
        @this_org_msg_after = create(:msg, :msg_template=>@this_org_template, :sent_at=>2.days.from_now)
        @other_org_template = create(:msg_template, :msg_category=>@category, :organization=>@other_org)
        @other_org_msg_1 = create(:msg, :msg_template=>@other_org_template, :sent_at=>@sent_at)
        @responsible_event = CustomerContactEvent.create(:customer_id=>@customer_from_this_org.id, :msg_id=>@this_org_msg_1.id)
        CustomerContactEvent.create(:customer_id=>@customer_from_this_org.id, :msg_id=>@this_org_msg_after.id)
        CustomerContactEvent.create(:customer_id=>@other_customer_from_this_org.id, :msg_id=>@this_org_msg_2.id)
        CustomerContactEvent.create(:customer_id=>@customer_from_other_org.id, :msg_id=>@other_org_msg_1.id)
      end
      
      it "associates the mailgun hook with the most recent customer contact" do
        post '/mailgun/webhook/open', @example_post
        wh = Mailgun::RawWebhook.last
        wh.email.should eq 'support@retentionfactory.com'
        wh.assumed_contact_event.should_not be_nil
        wh.assumed_contact_event.msg.id.should eq @this_org_msg_1.id
        wh.assumed_contact_event.id.should eq @responsible_event.id
      end  
      
      it "updates the contact event to say it was opened" do
        post '/mailgun/webhook/open', @example_post
        wh = Mailgun::RawWebhook.last
        wh.email.should eq 'support@retentionfactory.com'
        wh.assumed_contact_event.is_opened.should eq true
        wh.assumed_contact_event.is_clicked.should eq false
      end  
      
    end
  end
  
  describe "open" do
    before do 
      @example_post = {"my-custom-data"=>"{\"subject\":\"[support] track me\",\"from\":\"Support Messages \\u003Csupport@retentionfactory.com\\u003E\",\"site_account\":99}", "city"=>"Mountain View", "domain"=>"mg.retentionfactory.com", "device-type"=>"desktop", "client-type"=>"browser", "h"=>"103498c4a3ec621597dba96e76a8c90c", "region"=>"CA", "client-name"=>"Firefox", "user-agent"=>"Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.0.7) Gecko/2009021910 Firefox/3.0.7 (via ggpht.com GoogleImageProxy)", "country"=>"US", "client-os"=>"Windows", "tag"=>"site-account-99", "ip"=>"66.249.82.4", "message-id"=>"20140318000530.19857.89601@mg.retentionfactory.com", "recipient"=>"support@retentionfactory.com", "event"=>"opened", "timestamp"=>"1395101161", "token"=>"9l1qsdrp06pe4wt1nlug8wmajnnd71xt5yoj8jh6ajydo9k0p0", "signature"=>"60fb96d16c0f0b4a3196fb2678ddb1b9913126711b8a47c2c4d28d2391c99e35", "controller"=>"mailgun/webhooks", "action"=>"open"}
    end
 
    it "saves an open record" do
      post '/mailgun/webhook/open', @example_post
      open = Mailgun::Open.first
      open.should_not be_nil
      open.raw_webhook.should_not be_nil
      open.raw_webhook.mailgun_type.should eq 'opened'
    end  
  end
  
  describe "click" do
    before do
      @example_post = {"city"=>"San Francisco", "domain"=>"mg.retentionfactory.com", "device-type"=>"desktop", "my_var_1"=>"Mailgun Variable #1", "country"=>"US", "region"=>"CA", "client-name"=>"Chrome", "user-agent"=>"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31", "client-os"=>"Linux", "my-var-2"=>"awesome", "url"=>"http://mailgun.net", "ip"=>"50.56.129.169", "client-type"=>"browser", "recipient"=>"alice@example.com", "event"=>"clicked", "timestamp"=>"1395101534", "token"=>"0zug5j2ibnpbesl4gqh745j3o6unagf3t6qpkhuc-pkty-zz37", "signature"=>"9473ba35850bb36b2074db9bfe5266f2139c8482efb43b1c8d23af89a047d254"}
    end

    it "saves a click record" do
      post '/mailgun/webhook/click', @example_post
      result = Mailgun::Click.first
      result.should_not be_nil
      result.raw_webhook.should_not be_nil
      result.url_clicked.should eq "http://mailgun.net"
      result.raw_webhook.mailgun_type.should eq 'clicked'
    end  
  end

  describe "spam" do
    before do
      @example_post = {"Message-Id"=>"<20110215055645.25246.63817@mg.retentionfactory.com>", "attachment-count"=>"1", "domain"=>"mg.retentionfactory.com", "event"=>"complained"} 
    end

    it "saves a complaint record" do
      post '/mailgun/webhook/spam', @example_post
      result = Mailgun::SpamComplaint.first
      result.should_not be_nil
      result.raw_webhook.should_not be_nil
      result.raw_webhook.mailgun_type.should eq 'complained'
    end  
  end

  describe "bounce" do
    before do
      @example_post = {"Message-Id"=>"<20110215055645.25246.63817@mg.retentionfactory.com>", "attachment-count"=>"1", "domain"=>"mg.retentionfactory.com", "event"=>"bounced", "error" => 'the error', "code" => 'the code'} 
    end

    it "saves a bounce record" do
      post '/mailgun/webhook/bounce', @example_post
      result = Mailgun::Bounce.first
      result.should_not be_nil
      result.raw_webhook.should_not be_nil
      result.smtp_code.should eq 'the code'
      result.error_msg.should eq 'the error'
      result.raw_webhook.mailgun_type.should eq 'bounced'
    end  
  end
end
