class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string  "name", :null=>false
      t.string  "description", :null=>false
      t.string  "teaser", :null=>false
      t.float   "price", :null=>false
      t.integer "points", :null=>false
      t.string  "payment_provider_id", :null=>false
      t.string  "payment_provider_url", :null=>false
      t.string  "group",                :default => "paid", :null => false
    end
    
  create_table :plans_users do |t|
    t.integer "user_id",         :null => false
    t.integer "plan_id", :null => false
  end
    
  end
end
