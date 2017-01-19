
class Organization < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
        
  STORE_TYPE_SHOPIFY = "Shopify"
  STORE_TYPE_MANUAL = "Manual"
  
  after_create :generate_tracking_site_id!
  
  belongs_to :admin_user, :foreign_key=>'admin_user_id', :class_name=>"User"
  
    
  validates :type, inclusion: { in: ['Organization','ShopifyOrganization'], message: "%{value} is not a valid type"}
  validates :store_type, inclusion: {in: [STORE_TYPE_SHOPIFY, STORE_TYPE_MANUAL], message: "%{value} is not a valid store_type"}
  
  validates :type, :name, :store_url, :store_type, :email, :account_email, :currency_template_text, :currency_template_html, presence: true
  validates :currency, :tracking_site_id, presence: true, on: :update
   
  validates_each :currency_template_text, :currency_template_html do |record, attr, value|
    record.errors.add(attr, 'must contain {{amount}}') if !(value =~ /{{amount}}/)
  end
  
  
  def next_signup_page(current_user, request, controller) 
    Rails.logger.info "Checking next signup page for org #{self.to_log} of type #{self.class.name}"
    next_page = nil
    if controller.class.name != 'SplashController'
      if current_user.plans.length == 0
        Rails.logger.info "User does not have a plan, redirecting to plans page"
        next_page = '/splash/plans_and_pricing'
      else
        if self.needs_authorization?  && !current_user.can?(:configure_system)
          Rails.logger.info "User #{current_user.to_log} has not fully authorized for #{self.to_log}, redirecting to authorize at #{self.authorize_path}"
          next_page = self.authorize_path
        elsif !self.is_confirmed && !request.fullpath.match(/organizations\/\d+\/edit/)
          Rails.logger.info "User #{current_user.to_log} has not been confirmed, redirecting"
          next_page = "/organizations/#{self.id}/edit"
        elsif !current_user.has_been_welcomed? && !request.fullpath.match(/organizations\/\d+\/edit/)
          Rails.logger.info "User #{current_user.to_log} has not been welcomed, redirecting to welcome path #{self.welcome_location} for organiztion type #{self.class.name}"
          next_page =  welcome_location
        end
      end
    end
    Rails.logger.info "Next signup page for org #{self.to_log} of type #{self.class.name} is: [#{next_page}]"
    next_page    
  end
    
  def to_log
    "#{self.id}/#{self.class.name}/#{self.name}"
  end
  
  def needs_authorization?
    false  
  end

  def authorize_path
    Rails.error "[Notify] Called authorize_path on Organization, which should never happen"
    raise "Sorry, an error happened"   
  end
  
  def welcome_location
    '/welcome'  
  end
  
  def platform_specific_initialization(user)
  end
  
  def should_pay?
    false
  end

  def considered_installed?
    self.is_installed?
  end
  
  def uninstall!
    self.is_installed = false
    self.is_active = false
  end
  
  def considered_active?
    self.considered_installed?   
  end
  
  def self.installed
    Organization.joins(:admin_user).where(is_installed: true)
  end
  
  def self.active
    Organization.installed.where(is_active: true)
  end
  
  
  #all organizations that are active and also have not been contacted for that message type in x days
  def self.eligible_for(message_key, num_days_since_last_contact = 7)
    Organization.all
  end
  
  def latest_stat
    nil  
  end
  
  def to_currency_html(amount)
    if amount
      if self.currency_template_html.match('{{amount}}')
        self.currency_template_html.sub('{{amount}}', num(amount,2)).html_safe
      else
        number_to_currency(amount)
      end
    else
      "n/a"
    end
  end
  
  def to_currency_plaintext(amount)
    if amount
      if self.currency_template_text.match('{{amount}}')
        self.currency_template_text.sub('{{amount}}', num(amount,2))
      else
        number_to_currency(amount)
      end
    else
      "n/a"
    end
  end
  
  def pct(numerator, denominator, precision=1)
    if denominator.nil? || denominator <= 0
      "0%"
    else
      number_to_percentage((numerator.to_f/denominator) * 100, :precision=>precision)
    end  
  end
  
  def num(amount, precision=0)
    #TODO: localize
    number_with_precision(amount, delimiter: ',',separator: '.', precision: precision)  
  end
  
  def unknown_customer
    nil  
  end
  
  #used only for support really
  def self.short_list
    Organization.all.order('created_at desc').collect {|o| [o.id, o.name, o.class.name, o.store_type, "#{o.num_orders} orders"]}  
  end
  
  def self.by_tracking_site_id(id)
    rv = Organization.where(tracking_site_id: id).first
    rv
  end
  
  def self.default_organization
    Organization.where(name: 'Default').first
  end
  
  def account_for(site_key, name='default', organization=nil)
    self.admin_user.account_for site_key, name, self
  end

  def mailgun_account
    self.admin_user.account_for 'mailgun', 'default', self #not calling User.mailgun_account on purpose to avoid an infinite loop if we screwed something up in the data or accidentally deleted the admin token  
  end
  
  def self.with_active_account_for(account_key)
    Organization.joins(:admin_user => [{:site_accounts => :site}])
              .where(["(site_accounts.encrypted_token is not null  
                   or (sites.key = 'ga' and site_accounts.encrypted_field3 is not null ))
                      and sites.key = ?
                      ", account_key]).group('organizations.id')
  end
  
end