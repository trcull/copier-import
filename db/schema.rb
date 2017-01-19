# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160403053542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_invoices", force: true do |t|
    t.integer  "site_account_id",                            null: false
    t.integer  "accounting_invoice_type_id",                 null: false
    t.string   "contact_name",                               null: false
    t.datetime "issue_date",                                 null: false
    t.datetime "due_date",                                   null: false
    t.integer  "accounting_amount_type_id",                  null: false
    t.boolean  "posted",                     default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "accounting_invoices", ["accounting_amount_type_id"], name: "index_accounting_invoices_on_accounting_amount_type_id", using: :btree
  add_index "accounting_invoices", ["accounting_invoice_type_id"], name: "index_accounting_invoices_on_accounting_invoice_type_id", using: :btree

  create_table "accounting_line_items", force: true do |t|
    t.integer  "accounting_invoice_id"
    t.string   "description",           null: false
    t.decimal  "quantity",              null: false
    t.decimal  "unit_amount",           null: false
    t.string   "account_code",          null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "alerts", force: true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.integer  "source"
    t.integer  "level",           default: 100
    t.boolean  "acknowledged",    default: false
    t.datetime "acknowledged_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "billing_invoice_line_items", force: true do |t|
    t.string  "name"
    t.string  "description"
    t.float   "unit_price"
    t.integer "quantity"
    t.string  "item_id"
    t.string  "sales_tracking_code"
    t.integer "invoice_id",          null: false
    t.float   "cost_basis"
  end

  create_table "billing_invoices", force: true do |t|
    t.string   "billing_client_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "site_account_id",   null: false
  end



  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "exchange_rates", force: true do |t|
    t.datetime "quoted_at",                               null: false
    t.date     "as_of_dt",                                null: false
    t.string   "base_currency",                           null: false
    t.string   "quote_currency",                          null: false
    t.decimal  "mid_rate",       precision: 15, scale: 7, null: false
    t.decimal  "bid_rate",       precision: 15, scale: 7
    t.decimal  "ask_rate",       precision: 15, scale: 7
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fb_clients", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "fb_id",      null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fb_projects", force: true do |t|
    t.string   "name",                                    null: false
    t.string   "fb_id",                                   null: false
    t.float    "budget_dollars_internal", default: 0.0,   null: false
    t.float    "budget_dollars_billed",   default: 0.0,   null: false
    t.float    "current_total_internal",  default: 0.0,   null: false
    t.float    "current_total_billed",    default: 0.0,   null: false
    t.float    "profit_target_percent",   default: 0.3,   null: false
    t.boolean  "active",                  default: true,  null: false
    t.boolean  "hidden",                  default: false, null: false
    t.float    "project_billing_rate",    default: 0.0,   null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "user_id"
    t.float    "expenses_subtotal",       default: 0.0
    t.float    "labor_subtotal",          default: 0.0
    t.string   "labor_description"
    t.string   "expenses_description"
    t.string   "labor_rate_method"
    t.float    "yellow_budget_threshold", default: 0.8
    t.float    "red_budget_threshold",    default: 0.9
    t.datetime "last_time_entry_at"
    t.datetime "last_expense_entry_at"
    t.datetime "last_invoice_at"
    t.datetime "last_activity_at"
  end

  create_table "mailgun_bounces", force: true do |t|
    t.integer  "mailgun_raw_webhook_id"
    t.string   "smtp_code"
    t.text     "error_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailgun_clicks", force: true do |t|
    t.integer  "mailgun_raw_webhook_id"
    t.text     "url_clicked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailgun_opens", force: true do |t|
    t.integer  "mailgun_raw_webhook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailgun_raw_webhooks", force: true do |t|
    t.string   "mailgun_type"
    t.text     "parameters"
    t.integer  "site_account_id"
    t.string   "email"
    t.integer  "assumed_customer_contact_event_id"
    t.string   "from"
    t.text     "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assumed_user_contact_event_id"
    t.integer  "assumed_prospect_contact_event_id"
  end

  create_table "mailgun_spam_complaints", force: true do |t|
    t.integer  "mailgun_raw_webhook_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end


  create_table "organizations", force: true do |t|
    t.text     "name",                                                                              null: false
    t.integer  "admin_user_id",                                                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tracking_site_id"
    t.text     "store_url"
    t.string   "store_type",             default: "Manual",                                         null: false
    t.text     "address"
    t.text     "city"
    t.text     "country"
    t.text     "email"
    t.string   "platform_id"
    t.text     "phone"
    t.string   "state"
    t.string   "postal_code"
    t.string   "timezone"
    t.string   "currency"
    t.text     "logo_url"
    t.text     "alt_image_1_url"
    t.text     "alt_image_2_url"
    t.text     "alt_image_3_url"
    t.string   "currency_template_text", default: "${{amount}}",                                    null: false
    t.string   "currency_template_html", default: "${{amount}}",                                    null: false
    t.boolean  "needs_to_pay",           default: false,                                            null: false
    t.boolean  "is_exempt_from_paying",  default: false,                                            null: false
    t.boolean  "is_suspended",           default: false,                                            null: false
    t.datetime "last_nagged_at"
    t.datetime "first_needed_to_pay"
    t.boolean  "is_downloading",         default: false,                                            null: false
    t.string   "type",                   default: "Organization",                                   null: false
    t.boolean  "is_installed",           default: true,                                             null: false
    t.boolean  "is_active",              default: false,                                            null: false
    t.text     "account_email",          default: "support+unsetaccountemail@retentionfactory.com", null: false
    t.boolean  "is_confirmed",           default: false,                                            null: false
  end

  create_table "permissions", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions_roles", force: true do |t|
    t.integer  "role_id"
    t.integer  "permission_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.string  "name",                                  null: false
    t.text    "description",                           null: false
    t.string  "teaser",                                null: false
    t.float   "price",                                 null: false
    t.integer "points",                                null: false
    t.string  "payment_provider_id",                   null: false
    t.string  "payment_provider_url",                  null: false
    t.string  "group",                default: "paid", null: false
  end

  create_table "plans_users", force: true do |t|
    t.integer "user_id", null: false
    t.integer "plan_id", null: false
  end

  create_table "roles", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "site_accounts", force: true do |t|
    t.string   "type",             default: "SiteAccount", null: false
    t.integer  "site_id",                                  null: false
    t.integer  "user_id",                                  null: false
    t.integer  "organization_id",                          null: false
    t.string   "name",                                     null: false
    t.string   "site_user_id"
    t.string   "encrypted_token"
    t.string   "encrypted_secret"
    t.string   "encrypted_field1"
    t.string   "encrypted_field2"
    t.string   "encrypted_field3"
    t.string   "encrypted_field4"
    t.string   "encrypted_field5"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_accounts", ["organization_id", "user_id"], name: "index_site_accounts_on_organization_id_and_user_id", using: :btree
  add_index "site_accounts", ["site_id"], name: "index_site_accounts_on_site_id", using: :btree

  create_table "sites", force: true do |t|
    t.string   "key",                       null: false
    t.string   "name",                      null: false
    t.boolean  "active",     default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end


  create_table "user_organizations", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "organization_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_temporary_login_tokens", force: true do |t|
    t.string   "token",      null: false
    t.integer  "user_id",    null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_temporary_login_tokens", ["expires_at", "user_id"], name: "idx_user_tokens_on_expires", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                       default: "",                 null: false
    t.string   "encrypted_password",          default: "",                 null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_organization_id"
    t.string   "accept_terms",                default: "f",                null: false
    t.integer  "intended_plan_id"
    t.boolean  "is_disabled",                 default: false,              null: false
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "has_been_welcomed",           default: false,              null: false
    t.boolean  "needs_to_pay_old_do_not_use", default: false,              null: false
    t.string   "otp_secret",                  default: "base32secret3232", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "xerox_copiers", force: true do |t|
    t.string   "serial_number",                                                     null: false
    t.integer  "fb_client_id",                                                      null: false
    t.integer  "user_id",                                                           null: false
    t.string   "make"
    t.string   "model"
    t.string   "grouping"
    t.integer  "mono_base",                                     default: 0,         null: false
    t.decimal  "mono_overage",          precision: 6, scale: 4, default: 0.0,       null: false
    t.integer  "color_0_base",                                  default: 0,         null: false
    t.decimal  "color_0_overage",       precision: 6, scale: 4, default: 0.0,       null: false
    t.integer  "mono_color_1_base",                             default: 0,         null: false
    t.decimal  "mono_color_1_overage",  precision: 6, scale: 4, default: 0.0,       null: false
    t.integer  "color_level_2_base",                            default: 0,         null: false
    t.decimal  "color_level_2_overage", precision: 6, scale: 4, default: 0.0,       null: false
    t.integer  "color_level_3_base",                            default: 0,         null: false
    t.decimal  "color_level_3_overage", precision: 6, scale: 4, default: 0.0,       null: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.decimal  "base_rate",                                     default: 0.0,       null: false
    t.string   "tax_name"
    t.decimal  "tax_rate",              precision: 6, scale: 4
    t.string   "sales_tracking_code",                           default: "default"
  end

  add_index "xerox_copiers", ["user_id", "serial_number"], name: "index_xerox_copiers_on_user_id_and_serial_number", unique: true, using: :btree

end
