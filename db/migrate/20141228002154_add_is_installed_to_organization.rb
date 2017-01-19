class AddIsInstalledToOrganization < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.boolean :is_installed, null: false, default: true
      t.boolean :is_active, null: false, default: false
    end
  end
end
