
FactoryGirl.define do
  factory :customer do
    organization
    email {FactoryGirl.generate :email}
    org_id {FactoryGirl.generate :org_id}
    org_created_at {DateTime.now}
    
    factory :contactable_customer do
       org_created_at 100.days.ago
    end
    
  end
end