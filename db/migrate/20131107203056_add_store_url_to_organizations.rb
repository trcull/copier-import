class AddStoreUrlToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.string :store_url
    end
  end
end
