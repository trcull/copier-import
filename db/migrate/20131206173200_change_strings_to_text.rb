class ChangeStringsToText < ActiveRecord::Migration
  def change
    change_column :monthly_updates, :submitted_subject , :text
    change_column :monthly_updates, :submitted_body , :text
    change_column :monthly_updates, :approved_subject , :text
    change_column :monthly_updates, :approved_body , :text
    
    change_column :product_variants, :name, :text
    change_column :products, :name, :text
    change_column :tracking_ecommerce_items, :product_name, :text
    change_column :tracking_ecommerce_items, :product_image_url, :text
    change_column :tracking_ecommerce_items, :product_purchase_url, :text
    change_column :tracking_visitor_properties, :value, :text

  end
end
