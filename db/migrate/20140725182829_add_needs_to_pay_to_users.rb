class AddNeedsToPayToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :needs_to_pay, null: false, default: false
    end
  end
end
