require 'spec_helper'

describe Admin::ConfigurationController do
  admin_login_integration
  
  it "doesn't explode" do
    get '/admin/configuration'
  end
  
  it "does the panic button" do
    post '/admin/panic'
    MsgCategory.all.each do |cat|
      cat.is_disabled?.should be_true
    end
    MsgProvider.all.each do |p|
      p.is_disabled?.should be_true
    end
    ENV['PANIC'].should eq 'true'
  end
  
  it "stnds down" do
    post '/admin/panic'
    post '/admin/stand_down'
    MsgCategory.all.each do |cat|
      cat.is_disabled?.should be_false
    end
    MsgProvider.all.each do |p|
      p.is_disabled?.should be_false
    end
    ENV['PANIC'].should eq 'false'
  end

  after do
    ENV['PANIC'] = 'false'
  end
end
