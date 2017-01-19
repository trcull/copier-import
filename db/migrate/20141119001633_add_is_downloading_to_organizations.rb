class AddIsDownloadingToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.boolean :is_downloading, null: false, default: false
    end
  end
end
