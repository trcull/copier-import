# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :xerox_copier , :class=>Fb::XeroxCopier do
    serial_number Forgery::LoremIpsum.word
    user
    fb_client
  end
end
