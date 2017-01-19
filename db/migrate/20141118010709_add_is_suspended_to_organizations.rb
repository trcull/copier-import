class AddIsSuspendedToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.boolean :needs_to_pay, null: false, default: false
      t.boolean :is_exempt_from_paying, null: false, default: false
      t.boolean :is_suspended, null: false, default: false
      t.datetime :last_nagged_at, null: true
      t.datetime :first_needed_to_pay, null: true
    end
    
    rename_column :users, :needs_to_pay, :needs_to_pay_old_do_not_use
    
  end
end
