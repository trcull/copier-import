# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fb_project , :class=>Fb::FbProject do
    name Forgery::LoremIpsum.words
    fb_id "38" # the WL Prototype project, which is now defunct so shouldn't change much
    user
  end
end
