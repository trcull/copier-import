class CreateRolesAndPermissions < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :null=>false
      t.timestamps
    end

    create_table :permissions do |t|
      t.string :name, :null=>false
      t.timestamps
    end

    create_table :permissions_roles do |t|
      t.integer :role_id
      t.integer :permission_id
      t.timestamps
    end
    
    create_table :roles_users do |t|
      t.integer :user_id
      t.integer :role_id
      t.timestamps
    end
    
  end
end
