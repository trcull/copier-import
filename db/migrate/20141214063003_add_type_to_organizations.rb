class AddTypeToOrganizations < ActiveRecord::Migration
  def change
    change_column_default(:organizations, :store_type, 'Manual')
    change_table :organizations do |t|
      t.string :type, null: false, default: "Organization"
    end
    
    Organization.connection.execute("update organizations set type = 'ShopifyOrganization' where store_type = 'Shopify'")
  end
end
