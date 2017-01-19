require 'spec_helper'

describe Fb::RefreshAllClientsJob do
  it "correctly stores clients with similar ids across users" do
    user1 = create(:user)
    user2 = create(:user)
    same_fb_client_id = "1"
    fb_api_client1 = {"client_id" => same_fb_client_id, "organization" => "org1"} 
    fb_api_client2 = {"client_id" => same_fb_client_id, "organization" => "org2"}
    fb_client1 = subject.find_fb_client(fb_api_client1, user1.id)
    fb_client2 = subject.find_fb_client(fb_api_client2, user2.id)
    fb_client1.id.should_not == fb_client2.id
    fb_client1.name.should_not eq fb_client2.name
  end
  
  context "with fake HTTP calls" do
    before do
      @api = double('api')
      Fb::RfApi.stub(:new).and_return @api
      @user = create(:user)
      @site_account = @user.account_for('fb')
      #make the account look 'active'
      @site_account.token = "fake"
      @site_account.field1 = "fake"
      @site_account.secret = "fake"
      @site_account.save!
      #Fb::RfApi.stub(:has_authorized).and_return(true)
      @clients = [{'client_id'=>'123', 'organization'=>'updated org'}]
      @api.stub(:fb_clients).and_return @clients
    end
  
    it "doesn't explode" do
      expect {subject.perform(@user.id)}.to change {Fb::FbClient.count}.by(1)
      new_client = Fb::FbClient.last
      new_client.name.should eq 'updated org'
    end
    
  end
end
