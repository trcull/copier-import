require 'spec_helper'

describe Fb::Invoice do
  it "calculates due date to 30 with no terms" do
    fb_invoice = {"date" => "2007-06-23"}
    invoice = Fb::Invoice.new(fb_invoice, {})
    invoice.date.should eq "2007-06-23"
  end

  it "due date is settable" do
    fb_invoice = {"date" => "2007-06-23"}
    invoice = Fb::Invoice.new(fb_invoice, {})
    invoice.due_date = "2007-08-23".to_date
    invoice.due_date.should eq "2007-08-23".to_date
  end

  it "number is returned" do
    fb_invoice = {"number" => "1234"}
    invoice = Fb::Invoice.new(fb_invoice, {})
    invoice.number.should eq "1234"
  end

  
  it "client view method returns the link" do
    test_url = "http://something"
    fb_invoice = {"date" => "2007-06-23", "links" => {"client_view" => test_url}}
    invoice = Fb::Invoice.new(fb_invoice, {})
    invoice.client_view.should eq test_url
  end

  
end
