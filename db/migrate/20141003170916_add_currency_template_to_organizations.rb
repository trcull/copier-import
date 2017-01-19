class AddCurrencyTemplateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :currency_template_text, :string, null: false, default: '${{amount}}'
    add_column :organizations, :currency_template_html, :string, null: false, default: '${{amount}}'
  end
end
