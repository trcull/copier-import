require 'objspace'

class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :find_memory_leaks
  
  #turn on ssl
  # see: http://stackoverflow.com/questions/9027916/redirecting-from-http-mysite-com-to-https-secure-mysite-com
  if Rails.env.production?
    force_ssl :host => "app.retentionfactory.com"
  end

  #see: http://scottwb.com/blog/2013/02/06/hsts-on-rails/
  before_filter :strict_transport_security
  def strict_transport_security
    if request.ssl?
      response.headers['Strict-Transport-Security'] = "max-age=31536000; includeSubDomains"
    end
  end

  
  def index
    render text: "This is just an API"
  end
  

  protected

  def suppress_login
    @suppress_login = true  
  end
  
  def get_tracked_visitors
    session[:tracked_visitors]
  end
  
  def log_server_side_event!(category, action, name, value)
    if get_tracked_visitors().present? 
      get_tracked_visitors().each_value do |tracked_visitor|
        TrackingEvent.log_event(tracked_visitor.visitor_id, Rails.application.config.tracking_site_id, category, action, name, value)
        #also, update the customer id if it's not present
        if tracked_visitor.customer_id.nil?
          cust = current_user.make_customer_of_pollen!
          tracked_visitor.customer_id = cust.id
          tracked_visitor.is_processed = true
          tracked_visitor.save!
        end
      end
    end
  end
  
  def can!(permission)
    if current_user.can?(permission)
      true
    else
      render text: "forbidden", status: :forbidden
      false
    end
  end
  
  def check_signup_complete!
    if current_user.nil?
      Rails.logger.info "User is not signed in, redirecting to login page"
      redirect_to '/users/sign_up'
    else
      if current_user.current_organization.nil?
        Rails.logger.info "Organization missing for user #{current_user.to_log} and organization_id #{current_user.current_organization_id}"
        current_user.current_organization = current_user.organizations.first
        current_user.save
      end
      if current_user.current_organization.nil?
        Rails.logger.error "[NOTIFY] Organization STILL missing for user #{current_user.to_log} and organization_id #{current_user.current_organization_id}, signing them out"
        sign_out current_user
        redirect_to '/users/sign_in'
      else
        org = current_user.current_organization
        next_path = org.next_signup_page(current_user, request, self)
        if next_path
          redirect_to next_path
        end
      end
    end
  end
  
  def configure_permitted_parameters
     devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email) }
     devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :new_organization_name, :new_store_url, :new_store_type) }
     devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end  
  
  def authenticate_user_from_token!
    user_id = params[:user_id]
    given_token = params[:user_token]
    if user_id && given_token
      user_tokens = UserTemporaryLoginToken.where(:user_id=>user_id).where("expires_at > ?",[DateTime.now])
      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      user_tokens.each do |token|
        if Devise.secure_compare(token.token, given_token)
          user = User.find user_id
          if user
            Rails.logger.info "Logging in user #{user.to_log} from a token instead of a password"
            sign_in user, store: true
          end
        else
          #Rails.logger.debug "token #{token.token} does not match #{given_token}"
        end
      end
    end
  end
  

  def logged_in_user_belongs_to_organization!
    rv = true
    organization_id = params[:organization_id]
    #organization_id ||= session[:organization_id]
    organization_id ||= current_user.current_organization.id
    if organization_id.nil?
      render :status=>400, :json=> {:errors=>"missing organization_id parameter"}.to_json
      rv = false
    elsif current_user.can?(:configure_system) || current_user.organizations.any? {|o| o.id == organization_id.to_i}
      session[:organization_id] = organization_id
      org = Organization.find organization_id
      current_user.add_to_organization org
      current_user.current_organization = org
      @organization_id = organization_id
      @org = Organization.find @organization_id 
    else
      Rails.logger.warn "user is not part of organization: #{organization_id}"
      render :status=>403, :json=> {:errors=>"you don't have access to this organization"}.to_json
      rv = false
    end
    rv
  end


  # see: http://tmm1.net/ruby21-objspace/
  # see: http://tmm1.net/ruby21-rgengc/
  # see: https://www.airpair.com/ruby-on-rails/performance
  # see: https://devcenter.heroku.com/articles/tuning-glibc-memory-behavior
  #see: http://stackoverflow.com/questions/25429022/how-to-deal-with-ruby-2-1-2-memory-leaks
  #see: https://github.com/archan937/ruby-mass
  #see: https://github.com/ronen/bloat_check
  #see: http://cirw.in/blog/find-references
  #see: http://tmm1.net/ruby21-rgengc/
  #see: http://samsaffron.com/archive/2014/04/08/ruby-2-1-garbage-collection-ready-for-production
  #see: https://discussion.heroku.com/t/tuning-rgengc-2-1-on-heroku/359
  #see: http://www.atdot.net/~ko1/activities/2014_rubyconf_ph_pub.pdf
  def find_memory_leaks
    if ENV['MONITOR_MEMORY'] == 't'
      Rails.logger.info "GC STAT: #{GC.stat}"
      #Rails.logger.info "COUNT_OBJECTS: #{ObjectSpace.count_objects}"
      Rails.logger.info "COUNT_OBJECTS_SIZE: #{ObjectSpace.count_objects_size}"
      Rails.logger.info "COUNT_TDATA_OBJECTS: #{ObjectSpace.count_tdata_objects}"
      #Rails.logger.info "COUNT_NODES: #{ObjectSpace.count_nodes}"
      if params[:dump_heap]
        if params[:extra_detail]
          Rails.logger.info "DUMPING LARGE STRINGS"
          ObjectSpace.each_object(String) do |o|
            size=ObjectSpace.memsize_of(o) 
            Rails.logger.info "LARGE STRING: #{size} => #{o[0..50]}" if size > 1000
            Rails.logger.info "JUMBO STRING: #{size} => #{o[0..50]}" if size > 10000
          end
          Rails.logger.info "DUMPING PG CONNECTIONS"
          ObjectSpace.each_object(PG::Result) {|o|  Rails.logger.info ObjectSpace.memsize_of(o)}
          Rails.logger.info "DUMPING JSON STATES"
          ObjectSpace.each_object(JSON::Ext::Generator::State) {|o|  Rails.logger.info ObjectSpace.memsize_of(o) }
          Rails.logger.info "DUMPING JSON PARSERS"
          ObjectSpace.each_object(JSON::Ext::Parser) {|o|  Rails.logger.info ObjectSpace.memsize_of(o) }
        end
        Rails.logger.info "SYMBOL COUNT"
        ObjectSpace.reachable_objects_from_root.each_pair do |key, value|
          if key == 'symbols'
             Rails.logger.info "SYMBOL COUNT: #{value.length}"
          end
        end  
        
        Rails.logger.info "REACHABLE OBJECTS"
        ObjectSpace.reachable_objects_from_root.each_pair do |key,value|
          Rails.logger.info "#{key} => #{value.length}"
          if params[:extra_detail]
            value.each do |o|
              s = ObjectSpace.memsize_of(o)
              if s > 1000
                Rails.logger.info "BIG OBJECT: #{key} => #{s} => #{o.class.name}"
                Rails.logger.info "OBJECT WRAPPER #{s} => #{o.inspect}" if o.class.name == "ObjectSpace::InternalObjectWrapper"
                Rails.logger.info "CLASS #{s} => #{o.inspect}" if o.class.name == "Class"
                Rails.logger.info "MODULE #{s} => #{o.inspect}" if o.class.name == "Module"
              end
              if s > 50000
                Rails.logger.info "JUMBO OBJECT: #{key}  => #{s} => #{o.class.name} "
              end
            end
          end
        end
      end
    end  
  end


end
