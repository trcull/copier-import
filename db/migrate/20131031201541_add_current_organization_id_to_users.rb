class AddCurrentOrganizationIdToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :current_organization_id, :null=>true
    end
  end
end
