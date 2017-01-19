class CreateTrackingTables < ActiveRecord::Migration
  def change
    create_table :tracking_events do |t|
      t.string :visitor_id, :null=>false
      t.string :tracking_site_id, :null=>false
      t.string :category
      t.string :action
      t.string :name
      t.string :value
      t.datetime :created_at
    end

    create_table :tracking_visitors do |t|
      t.string :visitor_id, :null=>false
      t.string :tracking_site_id, :null=>false
      t.string :org_customer_id, :null=>false
      t.string :email, :null=>true
      t.datetime :org_created_at, :null=>true
      t.integer :organization_id, :null=>true
      t.integer :customer_id, :null=>true
      t.datetime :created_at
    end
    
    create_table :tracking_visitor_properties do |t|
      t.integer :tracking_visitor_id, :null=>false
      t.string :name, :null=>false
      t.string :value, :null=>false
    end
    
    create_table :tracking_ecommerce_items do |t|
      t.string :product_id, :null=>false
      t.integer :product_quantity, :null=>false
      t.string :product_name, :null=>true
      t.string :visitor_id, :null=>false
      t.string :tracking_site_id, :null=>false
      t.datetime :created_at
    end

    create_table :tracking_ecommerce_orders do |t|
      t.string :order_id, :null=>false
      t.float :grand_total, :null=>false
      t.string :visitor_id, :null=>false
      t.string :tracking_site_id, :null=>false
      t.datetime :created_at
    end
    
    change_table :organizations do |t|
      t.string :tracking_site_id
    end
  end
end
