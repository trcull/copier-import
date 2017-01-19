# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site_account do
    site 
    user 
    organization
    name 'default'
  end
end
