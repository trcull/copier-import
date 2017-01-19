
FactoryGirl.define do 
  factory :billing_invoice, :class=>Billing::Invoice do
    site_account
    billing_client_id Forgery::LoremIpsum.word    
  end
  
  factory :billing_line_item, :class=>Billing::LineItem do
    billing_invoice
    name Forgery::LoremIpsum.word
    description Forgery::LoremIpsum.words
    unit_price Forgery::Basic.number
    quantity Forgery::Basic.number
    item_id Forgery::LoremIpsum.word
    sales_tracking_code Forgery::LoremIpsum.word
  end
end