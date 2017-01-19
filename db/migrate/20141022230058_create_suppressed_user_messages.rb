class CreateSuppressedUserMessages < ActiveRecord::Migration
  def change
    create_table :suppressed_user_messages do |t|
      t.integer :user_id, null: false
      t.string :message_key, null: false
      t.timestamps
    end
  end
end
