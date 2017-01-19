require 'spec_helper'

describe Billing::LineItem do
  it "doesn't explode" do
    item = Billing::LineItem.new
  end

  it "has a working factory" do
    item = create(:billing_line_item)
  end  
end
