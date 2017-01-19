class AddAccountEmailToOrganization < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.text :account_email, null: false, default: 'support+unsetaccountemail@retentionfactory.com'
    end
    
    Organization.connection.execute("update organizations set account_email = email where account_email = 'support+unsetaccountemail@retentionfactory.com' and email is not null")
  end
end
