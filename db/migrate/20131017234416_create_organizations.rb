class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, :null=> false
      t.integer :admin_user_id, :null=>false
      t.timestamps
    end

    create_table :user_organizations do |t|
      t.string :user_id, :null=> false
      t.integer :organization_id, :null=>false
      t.timestamps
    end

  end
end
