
FactoryGirl.define do
  #use with: FactoryGirl.generate :email
  sequence :email do |n|
    "person#{n}@example.com"
  end
  
  sequence :org_id do |n|
    "org#{n}id"
  end
  
  sequence :name do |n|
    "Name Num #{n}"
  end
  
  sequence :url do |n|
    "https://pollen.io/test/#{n}.html"
  end
end