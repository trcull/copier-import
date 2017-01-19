class AddLogosToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.text :logo_url, null: true
      t.text :alt_image_1_url, null: true
      t.text :alt_image_2_url, null: true
      t.text :alt_image_3_url, null: true
    end
  end
end
