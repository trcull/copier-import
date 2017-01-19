class Billing::LineItem < ActiveRecord::Base
  self.table_name = "billing_invoice_line_items"
  
  belongs_to :billing_invoice, :class_name=>"Billing::Invoice", :foreign_key=>"invoice_id"
end