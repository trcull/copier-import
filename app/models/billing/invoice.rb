class Billing::Invoice < ActiveRecord::Base
  self.table_name = 'billing_invoices'  

  #attr_accessible :billing_client_id
  validates_presence_of :site_account
  has_many :line_items, :class_name => "Billing::LineItem", :foreign_key => "invoice_id"
  belongs_to :site_account
  
end