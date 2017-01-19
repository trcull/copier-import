class AddUsersExtendedFields < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :first_name, null: true
      t.string :last_name, null: true
    end
    
    change_table :organizations do |t|
      t.string :store_type, null: false, default: 'Shopify'
      t.string :address, null: true
      t.string :city, null: true
      t.string :country, null: true
      t.string :email, null: true
      t.string :platform_id, null: true
      t.string :phone, null: true
      t.string :state, null: true
      t.string :postal_code, null: true
      t.string :timezone, null: true
      t.string :currency, null: true
    end
  end
end
