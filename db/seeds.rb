# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

provider = MsgProvider.find_or_create_by(:key=>'internal_email') do |p|
    p.name="Internal Email"
    p.key="internal_email"
    p.save!
end

#note: because of the callbacks in user.rb, these roles must be created before my user is created
['Default','Admin', 'Copier Sales'].each do |name|
  Role.find_or_create_by(:name=>name) do |r|
    r.name = name
    r.save!
  end
end

[['mailgun','Mailgun'],
['shopify','Shopify'],
['ga','Google Analytics'],
['fb','Freshbooks'],
['soundscan','Soundscan']].each do |site|
  s = Site.find_or_create_by(:key=>site[0]) do |s|
    s.key = site[0]
    s.name = site[1]
  end  
end

me = User.where(:email=>'trcull@pollen.io').first
if me.nil?
  me_new = User.new
  me_new.email = 'trcull@pollen.io'
  me_new.password = 'foobar1234'
  me_new.password_confirmation = 'foobar1234'
  me_new.new_organization_name = "Pollen"
  me_new.new_store_url = "https://app.retentionfactory.com"
  me_new.new_store_type = Organization::STORE_TYPE_MANUAL
  me_new.save!
  mailgun = me_new.account_for 'mailgun'
  mailgun.token = ENV['MAILGUN_API_KEY']
  mailgun.save!
  me = me_new
end

['Default'].each do |name|
  o = Organization.where(:name=>name).first
  if o.nil?
    o = Organization.new
  end
  o.name = name
  o.admin_user_id = me.id
  o.store_type = 'Manual'
  o.type = "Organization"
  o.currency = 'USD'
  o.email = "support+#{name}@retentionfactory.com"
  o.store_url = "retentionfactory.com/#{name}"
  o.is_active = false
  o.is_installed = true
  puts "Setting #{me.to_log} to admin user for #{o.to_log}"
  o.save!
end

default_org = Organization.where(:name=>'Default').first

[:upload,:configure_system,:panic, :copier_import].each do |name|
  Permission.find_or_create_by(:name=>name) do |p|
    p.name = name
    p.save!
  end
end

Role.add_permission_to_role(:upload,'Admin')
Role.add_permission_to_role(:configure_system,'Admin')
Role.add_permission_to_role(:panic,'Admin')
Role.add_permission_to_role(:copier_import, 'Copier Sales')

me.remove_organizations!
me.add_to_all_organizations
me.add_to_all_roles
me.save!

User.find_or_create_by(:email=>'jesse@pahoda.com') do |jesse|
  jesse.email = 'jesse@pahoda.com'
  jesse.password = 'foobar1234'
  jesse.password_confirmation = 'foobar1234'
  jesse.new_organization_name = "Pahoda Image Products"
  jesse.new_store_url = "http://denvercopier.com/"
  jesse.new_store_type = Organization::STORE_TYPE_MANUAL
  jesse.save!
  mailgun = jesse.account_for 'mailgun'
  mailgun.token = ENV['MAILGUN_API_KEY']
  mailgun.save!
end

['jesse@pahoda.com','sales@pahoda.com'].each do |email|
  u = User.where(email: email).first
  if u.present?
    u.add_role 'Copier Sales'
  end  
end

['Pahoda Image Products'].each do |org_name|
  manual_org = Organization.where(name: org_name).first
  manual_org.store_type="Manual"
  manual_org.save
end

Organization.all.each{|org| org.generate_tracking_site_id!}

['Free','Basic','Pro','Enterprise'].each do |name|
  Plan.find_or_create_by(:name=>name) do |p|
    p.name = name
    p.description = "This is a great plan, please try it"
    p.teaser = "great value!"
    p.price = 0
    p.points = 0
    p.payment_provider_id="free"
    p.payment_provider_url='https://thedwick-llc.recurly.com/subscribe/rf-free'
    p.group = Plan::GROUP_FREE_PLAN
    p.save!
  end
end

if Rails.env.development?
  Plan.where(:name=>'Local Testing').destroy_all
  Plan.find_or_create_by(:name=>'Local') do |p|
    p.name = 'Local'
    p.description = "This is a great plan, please try it"
    p.teaser = "great value!"
    p.price = 0
    p.points = 10000000
    p.payment_provider_id="rf-test"
    p.payment_provider_url='https://thedwick-llc.recurly.com/subscribe/rf-test'
    p.group = Plan::GROUP_PAID_PLAN
    p.save!
  end
end


