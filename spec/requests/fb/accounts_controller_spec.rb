require 'spec_helper'

describe Fb::AccountsController do
  class FakeRequestToken
    attr_accessor :authorize_url
    def initialize()
      @authorize_url = "http://redirect.to/me"
    end
  end
  login_integration
  before do
    @api = double('api')
    Fb::RfApi.stub(:new).and_return @api
    site = create(:site, :key=>'fb')
    create(:site_account, :site=>site, :user=>@user)
    @request_token = FakeRequestToken.new
    @access_token = double("access_token")
    @access_token.stub(:token).and_return "atoken"
    @access_token.stub(:secret).and_return "asecret"
  end
  
  describe "connect_account" do
    before do
      @api.stub(:oauth_request_token).and_return(@request_token)
    end
    
    it "doesn't explode" do
      get "/fb/accounts/connect_account"
    end

    it "puts the request token in the session" do
      @api.should_receive(:oauth_request_token).and_return(@request_token)
      get "/fb/accounts/connect_account?name=featureviz"
      session[:fb_request_token].should eq @request_token
    end

    it "redirects to the authorization url" do
      get "/fb/accounts/connect_account?name=featureviz"
      response.should redirect_to @request_token.authorize_url
    end

    it "sets field1 of the new site account" do
      get "/fb/accounts/connect_account?name=featureviz"
      @user.account_for('fb').field1.should eq 'featureviz'
    end


    it "renders a page if the user's freshbooks site is missing" do
      get "/fb/accounts/connect_account"
      response.should render_template 'connect_account'
    end

  end
  
  describe "oauth_callback" do
    before do
      @api.stub(:oauth_access_token).and_return @access_token
      Fb::RefreshAllClientsJob.stub(:enqueue)
    end
    
    context "user authorized our app" do
      it "asks for an access token" do
        @api.should_receive(:oauth_access_token).and_return @access_token
        post "/fb/oauth_callback", {:oauth_verifier=>'fake', :fb_request_token=>@request_token}
      end
      
      it "saves the tokens for the user" do
        post "/fb/oauth_callback", {:oauth_verifier=>'fake',:fb_request_token=>@request_token}
        account = @user.account_for 'fb'
        account.token.should eq "atoken"
        account.secret.should eq "asecret"
      end
      
      it "should enqueue jobs to update the user" do
        Fb::RefreshAllClientsJob.should_receive(:enqueue)
        post "/fb/oauth_callback", {:oauth_verifier=>'fake',:fb_request_token=>@request_token}
      end
    end
  end
end
