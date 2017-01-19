class CreateMailgunWebhooks < ActiveRecord::Migration
  def change
    create_table :mailgun_raw_webhooks do |t|
      t.string :mailgun_type
      t.text :parameters
      t.integer :site_account_id
      t.string :email
      t.integer :assumed_msg_id
      t.string :from
      t.text :subject
      t.timestamps
    end
    
    create_table :mailgun_opens do |t|
      t.integer :mailgun_raw_webhook_id
      t.timestamps
    end

    create_table :mailgun_clicks do |t|
      t.integer :mailgun_raw_webhook_id
      t.string :url_clicked
      t.timestamps
    end

    create_table :mailgun_bounces do |t|
      t.integer :mailgun_raw_webhook_id
      t.string :smtp_code
      t.string :error_msg
      t.timestamps
    end

    create_table :mailgun_spam_complaints do |t|
      t.integer :mailgun_raw_webhook_id
      t.timestamps
    end

  end
end
