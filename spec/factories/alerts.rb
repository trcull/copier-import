# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :alert do
    user_id 1
    message "MyText"
    source 1
    level 1
    acknowledged false
    acknowledged_at "2012-11-15 15:37:10"
  end
end
