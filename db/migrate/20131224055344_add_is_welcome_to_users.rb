class AddIsWelcomeToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :has_been_welcomed, null: false, default: false
    end
  end
end
