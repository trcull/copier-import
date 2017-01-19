
FactoryGirl.define do
  factory :plan do
    name {FactoryGirl.generate :name}
    description {FactoryGirl.generate :name}
    teaser {FactoryGirl.generate :name}
    price 1.13
    points 3
    payment_provider_url "http://fuckoff.com"
    payment_provider_id {FactoryGirl.generate :name}
    group Plan::GROUP_PAID_PLAN
  end
end