module LoginMacros
  #use this for integration tests (ie. stuff in spec/requests)
  def login_integration
    before do 
      @user = FactoryGirl.create(:user)
      @org = @user.current_organization
      post user_session_path, :user => {:email => @user.email, :password => 'supersecretpasswordstuff'}
    end
  end

  def shopify_login_integration
    before do 
      @user = FactoryGirl.create(:shopify_user)
      @org = Organization.find @user.current_organization.id
      post user_session_path, :user => {:email => @user.email, :password => 'supersecretpasswordstuff'}
    end
  end

  def admin_login_integration
    before do 
      @user = FactoryGirl.create(:user)
      @user.add_to_all_roles
      @org = @user.current_organization
      post user_session_path, :user => {:email => @user.email, :password => 'supersecretpasswordstuff'}
    end
  end
  
  #use this for unit tests (ie. stuff in spec/controllers)
  def login
    before do 
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user)
      @org = @user.current_organization
      sign_in @user
    end
  end
end