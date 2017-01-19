 class SupportHelper
   def self.on_exception(msg, e)
      Rails.logger.error msg
      Rails.logger.error e.backtrace.join('\n')
      unless Rails.env.test?
        mail = Mailgun::RfApi.new Organization.default_organization.mailgun_account
        msg = "<html><body>
        <p>Unexpected error!</p>
        <p>#{msg}</p>
        <p>#{e.message}</p>
        <p>#{e.backtrace.join('<br/>')}</p>
        </body></html>"
      
        mail.send_msg "Exception Monitoring <support@retentionfactory.com>", "[support] Exception in RetentionFactory.com",
                     msg, msg, ["support@retentionfactory.com"]
      end     
   end
   
   def self.email(subject, body)
      Rails.logger.error "Support email #{subject}, body #{body}"
      unless Rails.env.test?
        mail = Mailgun::RfApi.new Organization.default_organization.mailgun_account
        msg = "<html><body>
        <p>Support Message</p>
        <p>#{body}</p>
        </body></html>"
      
        mail.send_msg "Support Messages <support@retentionfactory.com>", "[support] #{subject}",
                     msg, body, ["support@retentionfactory.com"]
      end     
   end
   
   def self.render_email(template, locals={})
     SupportHelper.render_view('app/views/emails', template, locals)
   end
   
   def self.render_view(dir, file, locals={})
     #see: http://stackoverflow.com/questions/9469825/why-uri-escape-fails-when-called-on-actionviewoutputbuffer
     '' + ActionView::Base.new(dir, locals, ActionController::Base.new).render(file: file, locals: locals)
   end
   
   def self.email_user(user, subject, template, locals={}) 
    if user.is_suppressed?(template)
      Rails.log.warn "[NOTIFY] tried to email #{template} to user #{user.to_log} even though that user has been suppressed for that message type."
    else
      msg = SupportHelper.render_email template, locals
      mail = Mailgun::RfApi.new user.mailgun_account
      unless Rails.env.test?
        mail.send_msg "Retention Factory Support <support@retentionfactory.com>", subject, msg, msg, [user.email]
      end
      user.mark_received!(template)
    end
   end
  
   def self.email_organization(org, subject, template, locals={}) 
      msg = SupportHelper.render_email template, locals
      mail = Mailgun::RfApi.new org.admin_user.mailgun_account
      unless Rails.env.test?
        mail.send_msg "Retention Factory Support <support@retentionfactory.com>", subject, msg, msg, [org.account_email]
      end
      org.admin_user.mark_received!(template)
      msg
   end
   
 end