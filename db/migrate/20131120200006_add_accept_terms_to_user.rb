class AddAcceptTermsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :accept_terms, null: false, default: false
      t.integer :intended_plan_id, null: true
    end
  end
end
