
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :user_organizations
  has_many :site_accounts
  has_and_belongs_to_many :organizations, :join_table=>:user_organizations
  has_and_belongs_to_many :roles#, :through=>:user_roles
  has_and_belongs_to_many :plans#, :through=>:user_plans
  belongs_to :current_organization, :class_name=>'Organization'
  
  validate :passwords_match, on: :create
  #having a hard time getting the form itself to pass this in correctly
  #validates :accept_terms, on: :create, inclusion: { in: [true], message: "Please accept the terms and conditions"}
  
  attr_accessor :new_organization_name, :new_store_url, :new_store_type
  
  after_create :after_user_created

  def passwords_match
    if self.password != self.password_confirmation
      self.errors.add(:password_confirmation, "Password and Password Confirmation must match")
    end
  end
  
  def is_suppressed?(template)
    false  
  end
  
  
  def should_pay?
    false
  end
  
  def needs_to_pay
    false
  end
  
  def total_plan_points
    self.plans.reduce(0) {|so_far, p| so_far + p.points }
  end
  
  def is_active?
    organizations.any? {|o| o.is_active?}  
  end
  
  def is_installed?
    organizations.any? {|o| o.is_installed?}
  end
  
  def has_received?(msg_key, since=20.years.ago)
    true
  end
  
  def mark_received!(msg_key)
    true
  end
  
  def remove_all_data
    
  end
    
  def plan_names
    if self.plans.length == 0
      "'Free Trial'"
    elsif self.plans.length == 1
      self.plans.first.name
    elsif self.plans.any? {|p| p.price > 0 }
      (self.plans.reject {|p| p.price <= 0}).collect{|p| "'#{p.name}'"}.join(' and ')
    else
      self.plans.collect{|p| "'#{p.name}'"}.join(' and ')
    end  
  end
  
  def after_user_created
    Rails.logger.info "User created #{self.inspect}"
    if self.valid? && self.id.present? 
      self.otp_secret = ROTP::Base32.random_base32
      if self.organizations.length == 0 
        o = Organization.new
          o.type = 'Organization'
        o.admin_user = self
        o.email = self.email
        o.account_email = self.email
        o.currency = 'USD'
        o.save!
        Rails.logger.info "Added organization #{o.inspect} to user #{self.inspect}"
        self.organizations<<o
      end
      if self.roles.length == 0
        r = Role.where(:name=>'Default').first
        self.roles << r
      end
      if self.plans.length == 0
        p = Plan.where(group: Plan::GROUP_FREE_PLAN).first
        self.plans << p if p.present?
      end
      self.save!
    end
  end
  
  def mailgun_account
    acct = self.account_for('mailgun') 
    if acct.token.nil? || acct.token == ''
      acct.token = Organization.default_organization.mailgun_account.token
    end
    acct 
  end
  
  def current_organization
    id = read_attribute(:current_organization_id)
    #default to first organization if they've never had one before.
    if id.nil? && self.organizations.length > 0
      rv = self.organizations.first
      self.current_organization = rv
      self.save!
    else
      rv = self.organizations.select{|o| o.id == id}.first
    end
    rv
  end
  
  #used only in the rails console when doing support
  def self.me
    User.where(email: 'trcull@pollen.io').first  
  end
  
  #used only for support really
  def self.short_list
    User.all.collect {|u| [u.id, u.email, u.current_organization.try(:id)]}  
  end
  
  #convenience method for showing what we commonly want to show in logs for a user
  def to_log
    "#{id}/#{email}"
  end
  
  def can?(permission, value=nil)
    rv=false
    self.roles.each do |role|
      if role.permissions.any? {|p| p.name == permission.to_s}
        rv = true
        break
      end
    end  
    rv
  end
  
  def add_to_organization(o)
    if !self.organizations.any?{|existing| existing.id == o.id}
      self.organizations << o
    end
  end  

  def remove_organizations!
    self.organizations.clear  
  end
  
  def add_role(name)
    r = Role.where(name: name).first
    if !self.roles.any?{|existing| existing.id == r.id}
      self.roles << r
    end
  end
  
  def plan_bucket
    if plans.length > 0
      plans.sort{|a,b| a.points <=> b.points}.first.name
    else
      'No Plan'
    end    
  end
  
  #see: https://github.com/mdp/rotp
  def generate_token
    rv = UserTemporaryLoginToken.new
    
    totp = ROTP::TOTP.new(self.otp_secret.to_s)
    rv.token = totp.now
    rv.expires_at = 3.days.from_now
    rv.user = self
    rv.save!
    rv
  end
  
  #just a convenience method, because the other was getting too long to type.
  def account_for(site_key, name='default', organization=nil)
    organization ||= current_organization
    find_or_create_site_account_for(site_key, name, organization)
  end
  
  def find_or_create_site_account_for(site_key, name, organization)
    site = Site.where(:key => site_key).first
    raise "site with key #{site_key} not found" if site.nil?
    raise "name may not be null" if name.nil?
    
    rv = nil
    site_accounts.each do |account|
      if account.site && account.site.id == site.id && account.organization && account.organization.id == organization.id && account.name == name
         rv = account
      end
    end  
    if rv.nil?
      rv = SiteAccount.create(site_id: site.id,
                        user_id: self.id,
                        organization_id: organization.id,
                        name: name)
      site_accounts << rv
      save!
    end
    rv
  end
  
end
