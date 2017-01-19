class AddIsOrgConfirmed < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.boolean :is_confirmed, null: false, default: false
    end
  end
end
