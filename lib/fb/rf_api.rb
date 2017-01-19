module Fb

  class DebuggingClient < FreshBooks::OAuthClient
    include HTTParty
    debug_output(STDOUT) #note: this isn't working, need to figure out why
    def initialize(site, key, secret, token, api_secret)
      super(site, key, secret, token, api_secret)
    end
  end
  
# see: http://developers.freshbooks.com/
class RfApi
  def initialize(site_account)
    @site_name = site_account.field1

    @api_token = site_account.token
    @api_secret = site_account.secret
  end
  
  def self.has_authorized?(user)
    site_account = user.account_for('fb')
    if not site_account.nil?
      return (site_account.field1.present? && site_account.field1.length > 0 && site_account.token.present? && site_account.token.length > 0 && site_account.secret.present? && site_account.secret.length > 0)
    end
  end
  
  def self.new_instance(site_account)

    Fb::RfApi.new(site_account)
  end
  
  def fb_connection()
     key = ENV["FRESHBOOKS_OAUTH_KEY"]
     secret = ENV["FRESHBOOKS_OAUTH_SECRET"]
    rv = Fb::DebuggingClient.new("#{@site_name}.freshbooks.com", key, secret, @api_token, @api_secret)
    return rv
  end

  def callbacks()
    fb_collect('callbacks','callback'){|conn, page| conn.callback.list(:page=>page)}
  end

  def create_callback(event, uri)
    conn = fb_connection()
    callback = {:callback=>{
      :event=> event,
      :uri =>uri
      }}
    Rails.logger.info "Creating callback: #{callback.inspect}"
    rv = conn.callback.create(callback)
  end

  def delete_callback(callback_id)
    conn = fb_connection()
    callback_id_struct = {:callback_id => callback_id}
    Rails.logger.info "deleting callback: #{callback_id}"
    rv = conn.callback.delete(callback_id_struct)
  end
  
  def verify_callback(callback_id, verify_token)
    conn = fb_connection()
    callback = {:callback=>{
      :callback_id=> callback_id,
      :verifier => verify_token
      }}
    Rails.logger.info "Verifying callback: #{callback.inspect}"
    rv = conn.callback.verify(callback)
  end

  
  def oauth_request_token()
    base = "https://#{@site_name}.freshbooks.com"
     url = "#{base}/oauth/oauth_request.php"
     key = ENV["FRESHBOOKS_OAUTH_KEY"]
     secret = ENV["FRESHBOOKS_OAUTH_SECRET"]
     callback = ENV["FRESHBOOKS_OAUTH_CALLBACK"]
     oauth = Infrastructure::Oauth.new( key,secret,{
                      :scheme=> :query_string,
                      :signature_method=>"PLAINTEXT",
                      :oauth_callback=>callback,
                      :authorize_path => "/oauth/oauth_authorize.php",
                      :access_token_path=>"/oauth/oauth_access.php",
                      :request_token_path=>"/oauth/oauth_request.php",
                      :site=>base})
     oauth.http.set_debug_output($stdout) 
     oauth.get_request_token(:oauth_callback=>callback)
  end
  
  def oauth_access_token(request_token, oauth_verifier)
    rv = request_token.get_access_token(:oauth_verifier=>oauth_verifier)
    @api_token = rv.token
    @api_secret = rv.secret
    rv
  end

  def get_taxes()
    fb_collect('taxes','tax'){|conn, page| conn.tax.list(:page=>page)}
  end
  
  def fb_client(client_id)
    client = fb_get("client") { |conn| conn.client.get(:client_id => client_id)}

    return client
  end

  def fb_clients
    fb_collect('clients','client'){|conn,page| conn.client.list(:page => page)}
  end

  def fb_invoice(invoice_id)
    Rails.logger.info "#{@site_name}.freshbooks.com"
    fb_invoice = fb_get("invoice") { |conn| conn.invoice.get(:invoice_id => invoice_id)}
    Rails.logger.info fb_invoice.inspect
    fb_invoice["contacts"]["contact"] = [fb_invoice["contacts"]["contact"]].flatten(1)
    return wrap_invoice(fb_invoice)
  end

  def fb_invoices(status)
    rv = fb_collect('invoices','invoice'){|conn,page|conn.invoice.list(:page=>page, :status => status)}
    wrapped = rv.map do |fb_invoice|
      fb_invoice["contacts"]["contact"] = [fb_invoice["contacts"]["contact"]].flatten(1)

      wrap_invoice(fb_invoice)
    end
    return wrapped
  end
  
  def create_invoice(client_id, lines, notes="")
    xml = SupportHelper.render_view('app/views/fb/xml_rendering','create_invoice',{:client_id=>client_id,
                                                                :lines=>lines})
    conn = fb_connection()
    invoice = {:invoice=>{
      :client_id=> client_id,
      :notes=>notes,
      :lines =>[]
    }}
    lines.each do |line|
      invoice[:invoice][:lines].push({:line=>{
        :name=>line[:name],
        :description=>line[:description],
        :unit_cost=>line[:unit_price],
        :quantity=>line[:qty],
        :type=>"Item",
        :tax1_name=>line[:tax_name],
        :tax1_percent=>line[:tax_rate]
      }})
    end
    rv = conn.invoice.create(invoice)
    Rails.logger.info "Invoice creation return value was: #{rv.inspect}"
    raise "Error creating invoice #{rv['error']}" if rv['error'].present?
    rv['invoice_id']
  end


  
  def fb_tasks_by_project(project_id)
    fb_collect('tasks','task'){|conn,page|conn.task.list(:page=>page,:project_id=>project_id)}
  end
  
  def fb_staff
    fb_collect('staff_members','member'){|conn,page|conn.staff.list(:page=>page)}
  end

  def fb_account()
    fb_get('staff'){|conn|conn.staff.current}
  end
  
  def fb_staffer_by_id(staff_id)
    fb_get('staff'){|conn|conn.staff.get(:staff_id=>staff_id)}
  end
  
  def fb_time_by_project(project_id)
    fb_collect('time_entries','time_entry'){|conn,page|conn.time_entry.list(:page=>page, :project_id=>project_id)}
  end
  
  def fb_projects
    fb_collect('projects','project'){|conn,page|conn.project.list(:page=>page)}
  end
  
  def fb_expenses
    fb_collect('expenses','expense'){|conn,page|conn.expense.list(:page=>page)}
  end
  
  def fb_payments_by_date_range(from_dt, to_dt)
    fb_collect('payments','payment'){|conn,page|conn.payment.list(:page=>page, :date_from=>from_dt, :date_to=>to_dt)}
  end
  
  def fb_expenses_by_project(project_id)
    fb_collect('expenses','expense'){|conn,page|conn.expense.list(:page=>page,:project_id=>project_id)}
  end
  
  private 
  def fb_collect(root_element_name, result_element_name, &block)
    rv = []  
    conn = fb_connection()
    page = 1
    pages = 1
    while page <= pages
      temp = yield conn, page
      if !temp[root_element_name].nil? && !temp[root_element_name]['pages'].nil?
        pages = temp[root_element_name]['pages'].to_i
      else
        Rails.logger.info "root element name #{root_element_name} is nil! #{temp}" if temp[root_element_name].nil?
        Rails.logger.info "pages attribute is nil! #{temp}" if !temp[root_element_name].nil? && temp[root_element_name]['pages'].nil?
        raise "root element #{root_element_name} is nil! #{temp}" if temp[root_element_name].nil?
      end
      page += 1
      if !temp[root_element_name].nil? && !temp[root_element_name][result_element_name].nil?
        if temp[root_element_name][result_element_name].kind_of?(Array)
          temp[root_element_name][result_element_name].each do |elem|
            rv.push(elem)
          end
        else
          #if there's only one result, the freshbooks api returns a bare hash instead of a hash inside an array
          elem = temp[root_element_name][result_element_name]
          rv.push(elem)        
        end
      end
    end
    return rv
  end

  def fb_get(root_element_name)
    conn = fb_connection()
    temp = yield conn
    if temp[root_element_name].nil?
      Rails.logger.info "root element #{root_element_name} is nil! #{temp}" 
      raise "root element #{root_element_name} is nil! #{temp}"
    end
    return temp[root_element_name] 
  end 
  
  def wrap_invoice(fb_invoice)
    client = fb_client(fb_invoice["client_id"])
    fb_user = fb_account()
    rv = Fb::Invoice.new(fb_invoice, client, fb_user, {})
    #Rails.logger.info "Got invoice from Freshbooks: #{rv.inspect}"
    rv
  end
  
  def post(url, params)
    real_url = "#{url}?".concat(params.collect{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&"))
    request = Net::HTTP::Post.new(real_url)
    request.set_form_data(params)
    do_request real_url, request
  end
  
  private
  
  
 def do_request(url, request, suppress_debug_log=false)
   parsed = URI.parse(url)
    net = Net::HTTP.new(parsed.host, parsed.port)
    net.use_ssl = true
    net.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
    if !suppress_debug_log
      #uncomment for debugging
      #TODO: use rails logger instead of stdout
      net.set_debug_output STDOUT #useful to see the raw messages going over the wire
    else 
      net.set_debug_output nil
    end
    net.read_timeout = 5
    net.open_timeout = 5
    Rails.logger.debug "making call to freshbooks"
    response = net.start do |http|
      http.request(request)
    end
    if response.code.to_i > 399 || response.code.to_i < 200
      raise response.code + ":" + response.body # Don't raise an error here; the caller will handle it
    end
    Rails.logger.debug "finished call to freshbooks"
    response
  end  
    
end
end
