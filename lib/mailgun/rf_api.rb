RestClient.log =
  Object.new.tap do |proxy|
    def proxy.<<(message)
      #Rails.logger.info message
    end
  end

class Mailgun::RfApi < AbstractApi
  def initialize(account)
    super()
    @protocol = 'https'
    @use_ssl = true
    @port = 443
    @host = "api.mailgun.net"
    if account.field1.present? && account.field1.length > 0
      @domain = account.field1
    else 
      @domain = "mg.retentionfactory.com"
    end
    @root_path = "/v2/#{@domain}"        
    if account.field2.present? && account.field2.length > 0
      @bcc = account.field2
    else
      @bcc = "support@retentionfactory.com"
    end
    #@root_path = "/v2/retentionfactory.mailgun.org"
    @auth_prefix = "api:#{account.token}@"
    @site_account = account
  end

  def send_msg(from, subject, html_body, text_body, tos, variable_substitutions=Hash.new, tracking_vars=Hash.new)
    if @site_account.token.nil? || @site_account.token.length == 0
      msg = "[NOTIFY]==========Mailgun token for user #{@site_account.user.to_log} and org #{@site_account.organization.to_log} is empty!!================="
      Rails.logger.warn msg
      raise msg
    end
    if !(ENV['PANIC'] && ENV['PANIC'] == 'true')
      data = Hash.new
      data[:from] = from
      Rails.logger.info "Sending message from #{from} with subject #{subject} to #{tos.length} recipients"
      data[:to] = tos.join(",")
      data[:bcc] = @bcc unless @bcc.nil?
      data[:subject] = subject
      data[:text] = text_body
      data[:html] = html_body
      tags = [subject, from, "site-account-#{@site_account.id}"]
      data['o:tag'] = tags
      data['o:tracking'] = 'yes'
      data['o:tracking-clicks'] = 'yes'
      data['o:tracking-opens'] = 'yes'
      data['o:dkim'] = 'yes'
      tracking_vars[:subject] = subject
      tracking_vars[:from] = from
      tracking_vars[:site_account] = @site_account.id
      data['v:my-custom-data'] = tracking_vars.to_json
      tos.each do |to|
        if variable_substitutions[to].nil?
          variable_substitutions[to] = {}
        end
        unsubscribe_id = CGI::escape "#{@site_account.user.current_organization.id}-rf-#{to}"
        variable_substitutions[to]['unsubscribe_path'] = "unsubscribe/#{unsubscribe_id}"
      end
      data['recipient-variables'] = variable_substitutions.to_json
      Rails.logger.info "Sending email '#{subject}' from '#{from}' of domain '#{@domain}' to addresses #{tos.inspect}"
      do_send_msg data
    else
      Rails.logger.warn "[NOTIFY]====THE PANIC BUTTON HAS BEEN LATCHED, SO REFUSING TO SEND EMAIL====="
    end
    Rails.logger.info "Done sending email '#{subject}' from '#{from}'"
  end

  def do_send_msg(data)
    begin
      url = "https://#{@auth_prefix}#{@host}:#{@port}#{@root_path}/messages"
      Rails.logger.info "Sending to url #{url}"
      Rails.logger.info "Sending data #{data.inspect}"
      RestClient.post url, data
    rescue Exception => e
      Rails.logger.error "[NOTIFY] Caught exception #{e.message} trying to send email '#{data.inspect}'"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
  
  def delete_webhooks
    existing = self.list_webhooks
    existing.each do |hook|
      url = "https://#{@auth_prefix}#{@host}:#{@port}/v2/domains/#{@domain}/webhooks/#{hook[:name]}"
      Rails.logger.info "[NOTIFY] Deleting mailgun webhook #{hook[:name]}"
      RestClient.delete url 
    end
  end
  
  def reregister_webhooks
    delete_webhooks
    ['bounce','spam','click','open'].each do |hook_name|
      url = "https://#{@auth_prefix}#{@host}:#{@port}/v2/domains/#{@domain}/webhooks"
      data = {id: hook_name, url: callback_for(hook_name)}
      Rails.logger.info "[NOTIFY] Creating mailgun webhook #{hook_name}"
      RestClient.post url, data     
    end    
  end
  
  def callback_for(type)
    "https://#{Rails.application.config.webhook_host}/mailgun/webhook/#{type}"  
  end

  
  def list_webhooks
    url = "https://#{@auth_prefix}#{@host}:#{@port}/v2/domains/#{@domain}/webhooks"
    response = RestClient.get url
    rv = []
    body = response.body
    the_list = JSON.parse body, {symbolize_names: true}
    the_list[:webhooks].each_pair do |hook_name, hook_body|
      hook = ApiResult.new
      hook[:name] = hook_name
      hook[:url] = hook_body[:url]
      rv << hook
    end
    rv
  end
end