class CreateUserTemporaryLoginTokens < ActiveRecord::Migration
  def change
    create_table :user_temporary_login_tokens do |t|
      t.string :token, null: false
      t.integer :user_id, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    
    add_index "user_temporary_login_tokens", ["expires_at","user_id"], name: "idx_user_tokens_on_expires", unique: true, using: :btree
    
    change_table :users do |t|
      t.string :otp_secret, null: false, default: 'base32secret3232'
    end
  end
end
