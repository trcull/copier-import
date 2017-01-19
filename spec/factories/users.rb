# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email {Forgery::Email.address }
    password "supersecretpasswordstuff"
    
    has_been_welcomed true
    
    before(:create) do |user, evaluator|
      user.new_organization_name = FactoryGirl.generate :name
      user.new_store_url = 'http://mystore.com'
      user.new_store_type = Organization::STORE_TYPE_MANUAL
      user.password_confirmation = "supersecretpasswordstuff"
    end
    
    after(:create) do |user, evaluator|
      unless user.current_organization
        l = UserOrganization.new
        l.organization = FactoryGirl.create(:organization, :admin_user_id=>user.id, :is_active=>true, :is_installed=>true)
        l.user = user
        l.save!
        user.organizations << l.organization
        user.current_organization = l.organization
      end 
      
      user.current_organization.update(is_confirmed: true)     
      
      plan = Plan.where(name: 'Free').first
      user.plans << plan
      user.save!
    end

    factory :shopify_user do
      after(:create) do |user, evaluator|
        org = user.current_organization
        org.store_type = Organization::STORE_TYPE_SHOPIFY
        org.type = 'ShopifyOrganization'
        org.save
        user.clear_association_cache
      end  
    end    
  end

end
