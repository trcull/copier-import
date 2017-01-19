
class Mailgun::Open < ActiveRecord::Base
  self.table_name = 'mailgun_opens'
  belongs_to :raw_webhook, :foreign_key=> 'mailgun_raw_webhook_id',:class_name=>'Mailgun::RawWebhook'
  
end