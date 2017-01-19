require 'spec_helper'

describe Billing::Invoice do
  it "doesn't explode" do
    invoice = Billing::Invoice.new
  end
  
  it "has a working factory" do
    invoice = create(:billing_invoice)
  end
end