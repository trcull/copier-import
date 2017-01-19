# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site , :class=> Site do
    name {FactoryGirl.generate :name}
    key {FactoryGirl.generate :name}
    active true
  end
end
