
FactoryGirl.define do
  factory :organization do
    name {FactoryGirl.generate :name}
    admin_user {|f| f.association(:user)}
    is_active true
    is_installed true
    email {FactoryGirl.generate :email}
    account_email {FactoryGirl.generate :email}
    currency 'USD'
    store_type 'Manual'
    type 'Organization'
    store_url {FactoryGirl.generate :name}
    is_confirmed true
    
    after(:create) { |o|
        admin_user = o.admin_user
        admin_user.organizations << o
        admin_user.current_organization = o
        admin_user.save
      }
  end

  factory :shopify_organization do
    type "ShopifyOrganization"
    store_type "Shopify"
    name {FactoryGirl.generate :name}
    admin_user {|f| f.association(:user)}
    email {FactoryGirl.generate :email}
    account_email {FactoryGirl.generate :email}
    currency 'USD'
    store_url {FactoryGirl.generate :name}
    is_confirmed true
    
    after(:create) { |o|
        admin_user = o.admin_user
        admin_user.organizations << o
        admin_user.current_organization = o
        admin_user.save
      }
  end

end