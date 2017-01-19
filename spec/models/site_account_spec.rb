require 'spec_helper'

describe SiteAccount do
  it "shouldn't explode" do
    create(:site_account)
  end
end