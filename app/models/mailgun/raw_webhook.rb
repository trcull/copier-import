
class Mailgun::RawWebhook < ActiveRecord::Base
  OPENED='opened'
  CLICKED='clicked'
  SPAM='complained'
  BOUNCED='bounced'
  
  self.table_name = "mailgun_raw_webhooks"
  belongs_to :assumed_contact_event, :foreign_key=> 'assumed_customer_contact_event_id',:class_name=>'CustomerContactEvent'
  belongs_to :assumed_user_contact_event, :foreign_key=> 'assumed_user_contact_event_id',:class_name=>'UserContactEvent'
  belongs_to :assumed_prospect_contact_event, :foreign_key=> 'assumed_prospect_contact_event_id',:class_name=>'ProspectMsg'
  belongs_to :site_account
  
  def find_assumed_msg!
    if assumed_contact_event.nil?
      dt = self.created_at.nil? ? DateTime.now : self.created_at
      read_only_contact_event = CustomerContactEvent.joins([:customer,:msg])
                                .where('msgs.sent_at is not null and msgs.sent_at <= :dt and customers.email = :email', {dt: dt, email: self.email})
                                .order("msgs.sent_at desc")
                                .first
      if read_only_contact_event
        #because we used a joins above, it's read only so we need to fetch an ediable
        contact_event = CustomerContactEvent.find read_only_contact_event.id
        self.assumed_contact_event = contact_event
        if self.mailgun_type == OPENED
          contact_event.is_opened = true
        elsif self.mailgun_type == CLICKED
          contact_event.is_clicked = true
        elsif self.mailgun_type == SPAM
          contact_event.is_spam = true
        elsif self.mailgun_type == BOUNCED
          contact_event.is_bounced = true
        else
          Rails.logger.warn "unrecognized mailgun_type #{self.mailgun_type}"
        end
        contact_event.save!
      else 
        ro_user_contact_event = UserContactEvent.joins([:user])
                                    .where('user_contact_events.created_at <= :dt and users.email = :email', {dt: dt, email: self.email})
                                    .order('user_contact_events.created_at desc')
                                    .first
        if ro_user_contact_event
          user_contact_event = UserContactEvent.find ro_user_contact_event.id
          self.assumed_user_contact_event = user_contact_event
          if self.mailgun_type == OPENED
            user_contact_event.is_opened = true
          elsif self.mailgun_type == CLICKED
            user_contact_event.is_clicked = true
          elsif self.mailgun_type == SPAM
            user_contact_event.is_spam = true
          elsif self.mailgun_type == BOUNCED
            user_contact_event.is_bounced = true
          else
            Rails.logger.warn "unrecognized mailgun_type #{self.mailgun_type}"
          end
          user_contact_event.save!          
        else
          ro_prospect_contact_event = ProspectMsg.joins([:prospect])
                                    .where('prospect_msgs.created_at <= :dt and prospects.email = :email', {dt: dt, email: self.email})
                                    .order('prospect_msgs.created_at desc')
                                    .first
          if ro_prospect_contact_event
            prospect_contact_event = ProspectMsg.find ro_prospect_contact_event.id
            self.assumed_prospect_contact_event = prospect_contact_event
            if self.mailgun_type == OPENED
              prospect_contact_event.is_opened = true
            elsif self.mailgun_type == CLICKED
              prospect_contact_event.is_clicked = true
            elsif self.mailgun_type == SPAM
              prospect_contact_event.is_spam = true
            elsif self.mailgun_type == BOUNCED
              prospect_contact_event.is_bounced = true
            else
              Rails.logger.warn "unrecognized mailgun_type #{self.mailgun_type}"
            end
            prospect_contact_event.save!          
          end
        end
      end
    end
  end
end