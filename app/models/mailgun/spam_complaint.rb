
class Mailgun::SpamComplaint < ActiveRecord::Base
  self.table_name = 'mailgun_spam_complaints'
  belongs_to :raw_webhook, :foreign_key=> 'mailgun_raw_webhook_id',:class_name=>'Mailgun::RawWebhook'
  
end