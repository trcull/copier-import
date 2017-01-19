class Site < ActiveRecord::Base
  SHOPIFY='shopify'
  MAILGUN='mailgun'
  GOOGLE_ANALYTICS='ga'
  FRESHBOOKS='fb'
  
  def self.shopify
    Site.where(key: SHOPIFY).first
  end
  
  def self.mailgun
    Site.where(key: MAILGUN).first
  end
  
  def self.google_analytics
    Site.where(key: GOOGLE_ANALYTICS).first  
  end
  
  #convenience method for showing what we commonly want to show in logs for a user
  def to_log
    "#{id}/#{name}"
  end
  
end
