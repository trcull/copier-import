require 'spec_helper'

describe OrganizationsController do
  login_integration

  describe "select" do
    it "doesn't explode" do
      get "/organization/#{@org.id}/select"
    end
  end
  
  describe "edit" do
    it "doesn't explode" do
      get "/organizations/#{@org.id}/edit" 
    end 
  end
  
  describe "update" do
    before do
      @attrs = @org.attributes
    end
    
    it "doesn't explode" do
      put "/organizations/#{@org.id}", {organization: @attrs}
    end
  end
end
