require 'spec_helper'

describe Admin::UsersController do
  admin_login_integration
  
  describe "edit" do
    it "doesn't explode" do
      get "/admin/users/#{@user.id}/edit"
    end
  end
  
  describe "index" do
    it "doesn't explode" do
      get "/admin/users"
    end
  end
  
  describe "traffic" do
    it "doesn't explode" do
      id = Organization.pollen_organization.tracking_site_id
      TrackingPageview.log_event('a',id,'http://pollen.io','http://www.google.bg/url?sa=t&rct=j&q=&esrc=s&source=web&cd=8&ved=0CE8QFjAH&url=http%3A%2F%2Fwww.retentionfactory.com%2F2014%2F09%2Fhow_to_create_an_email_course_on_mailchimp.html&ei=cdtPVKi5LqXnygP_94Jo&usg=AFQjCNEQ9CBC11t6SHJqN35hx1OZ9_ZxXQ&sig2=r1WJxhHhLet5K6SQEaqgLA&bvm=bv.78597519,d.bGQ&cad=rja')
      TrackingEvent.log_event('b',id,'some category','some action','some name',22)
      get '/admin/traffic' 
    end
  end
  
  describe "email_users" do
    before do
      @u1 = create(:user)
      @u2 = create(:user)
      
    end
    
    it "doesn't explode" do
      get "/admin/email_users"
    end
    
    it "tries to send an email for each selected user" do
      Messaging::EmailUsersJob.should_receive(:enqueue)
      post "/admin/email_users", {subject:"my subject", body:"some body", tos: [@u1.id]}.to_json, json_headers 
    end
  end
end
