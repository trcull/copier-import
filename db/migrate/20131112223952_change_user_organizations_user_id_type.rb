class ChangeUserOrganizationsUserIdType < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE user_organizations ALTER COLUMN user_id TYPE integer USING (user_id::integer);"
    #change_column :user_organizations, :user_id, :integer
  end
  
  def self.down
    change_column :user_organizations, :user_id, :string
  end
end
