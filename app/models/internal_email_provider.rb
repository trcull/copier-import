class InternalEmailProvider < MsgProvider
  def send_msg(user, msg_template, tos, configs, override_do_not_send=false)
    org = msg_template.organization
    customers = Customer.where(organization_id: org.id, email: tos)   
    _do_send_msg(user, msg_template, tos, customers, configs, override_do_not_send)
  end
  
  def send_to_customers(user, msg_template, customers, configs)
    customers = customers.reject {|c| c.email == '' || c.email.nil? || c.is_unknown}
    if customers.length > 2500
      #TODO: put a flag on the organization to allow sending more if they're super special
      Rails.logger.error "[NOTIFY]=====TRIED TO SEND MORE THAN 2500 EMAILS AT ONCE, WHICH IS PROBABLY A BUG.  Trimming down to 2500 instead #{msg_template.msg_category.name} for user #{user.to_log}==========="
      customers = customers[0..2500]    
    end
    customers.each_slice(200) do |slice|
      tos = slice.collect {|c| c.email}      
      _do_send_msg(user, msg_template, tos, slice, configs)
    end
  end

  def _do_send_msg(user, msg_template, tos, customers, configs, override_do_not_send=false)
    org = msg_template.organization
    msg = nil
    if is_disabled?
      Rails.logger.error "[NOTIFY]=====INTERNAL EMAIL PROVIDER IS DISABLED, REFUSING TO SEND EMAIL for user #{user.to_log} and template #{msg_template.id}===="
    elsif msg_template.msg_category.is_disabled?
      Rails.logger.error "[NOTIFY]=====CATEGORY #{msg_template.msg_category.name} IS DISABLED, REFUSING TO SEND EMAIL for user #{user.to_log} and template #{msg_template.id}===="
    else
      msg = Msg.create(msg_template_id: msg_template.id, sent_at: Time.now)
      api = Mailgun::RfApi.new(user.mailgun_account)
      html_body = substitute_vars(msg_template.html_text, msg_template)
      text_body = substitute_vars(msg_template.plain_text, msg_template)
      subject = substitute_vars(msg_template.subject, msg_template)
      CustomerContactEvent.transaction do 
        customers.each do |customer| 
          if customer.has_opted_out? && !override_do_not_send
            Rails.logger.info "removing customer #{customer.to_log} because they have opted out"
            tos.delete(customer.email)
          else
            customer.contacted_for!(msg)
          end
        end
      end
      if tos.length > 0
        api.send_msg(msg_template.from, subject, html_body, text_body, tos, configs)
      else
        Rails.logger.warn "WARNING: not actually sending message because the tos list is empty: #{msg_template.inspect} with configs #{configs.inspect}"
      end 
    end
    msg
  end

  def substitute_vars(text, msg_template)
    rv = msg_template.replace_vars(text)
    rv
  end
end