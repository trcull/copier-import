class CreateSiteAccount < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :key, :null=>false
      t.string :name, :null=>false
      t.boolean :active, :null=>false, :default=>true
      t.timestamps  
    end
    
    create_table :site_accounts do |t|
      t.string :type, :null=>false, :default=>"SiteAccount"
      t.integer :site_id, :null=> false
      t.integer :user_id, :null=>false
      t.integer :organization_id, :null=>false
      t.string :name, :null=>false
      t.string :site_user_id, :null=>true
      t.string :encrypted_token, :null=>true
      t.string :encrypted_secret, :null=>true
      t.string :encrypted_field1, :null=>true
      t.string :encrypted_field2, :null=>true
      t.string :encrypted_field3, :null=>true
      t.string :encrypted_field4, :null=>true
      t.string :encrypted_field5, :null=>true
      t.timestamps
    end
    
    add_index :site_accounts, [:site_id]
    add_index :site_accounts, [:organization_id, :user_id]
  end
end
