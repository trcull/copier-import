# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :fb_id do |n|
    "#{n}"
  end
  
  factory :fb_client , :class=>Fb::FbClient do
    user
    fb_id {FactoryGirl.generate(:fb_id)}
    name Forgery::LoremIpsum.word
  end
end
