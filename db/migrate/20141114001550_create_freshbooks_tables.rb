class CreateFreshbooksTables < ActiveRecord::Migration
  def change
  create_table "accounting_invoices", :force => true do |t|
    t.integer  "site_account_id",                               :null => false
    t.integer  "accounting_invoice_type_id",                    :null => false
    t.string   "contact_name",                                  :null => false
    t.datetime "issue_date",                                    :null => false
    t.datetime "due_date",                                      :null => false
    t.integer  "accounting_amount_type_id",                     :null => false
    t.boolean  "posted",                     :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "accounting_invoices", ["accounting_amount_type_id"], :name => "index_accounting_invoices_on_accounting_amount_type_id"
  add_index "accounting_invoices", ["accounting_invoice_type_id"], :name => "index_accounting_invoices_on_accounting_invoice_type_id"

  create_table "accounting_line_items", :force => true do |t|
    t.integer  "accounting_invoice_id"
    t.string   "description",           :null => false
    t.decimal  "quantity",              :null => false
    t.decimal  "unit_amount",           :null => false
    t.string   "account_code",          :null => false
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "alerts", :force => true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.integer  "source"
    t.integer  "level",           :default => 100
    t.boolean  "acknowledged",    :default => false
    t.datetime "acknowledged_at"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "billing_invoice_line_items", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.float   "unit_price"
    t.integer "quantity"
    t.string  "item_id"
    t.string  "sales_tracking_code"
    t.integer "invoice_id",          :null => false
    t.float   "cost_basis"
  end

  create_table "billing_invoices", :force => true do |t|
    t.string   "billing_client_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "site_account_id",   :null => false
  end

  create_table "fb_clients", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "fb_id",      :null => false
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fb_projects", :force => true do |t|
    t.string   "name",                                       :null => false
    t.string   "fb_id",                                      :null => false
    t.float    "budget_dollars_internal", :default => 0.0,   :null => false
    t.float    "budget_dollars_billed",   :default => 0.0,   :null => false
    t.float    "current_total_internal",  :default => 0.0,   :null => false
    t.float    "current_total_billed",    :default => 0.0,   :null => false
    t.float    "profit_target_percent",   :default => 0.3,   :null => false
    t.boolean  "active",                  :default => true,  :null => false
    t.boolean  "hidden",                  :default => false, :null => false
    t.float    "project_billing_rate",    :default => 0.0,   :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "user_id"
    t.float    "expenses_subtotal",       :default => 0.0
    t.float    "labor_subtotal",          :default => 0.0
    t.string   "labor_description"
    t.string   "expenses_description"
    t.string   "labor_rate_method"
    t.float    "yellow_budget_threshold", :default => 0.8
    t.float    "red_budget_threshold",    :default => 0.9
    t.datetime "last_time_entry_at"
    t.datetime "last_expense_entry_at"
    t.datetime "last_invoice_at"
    t.datetime "last_activity_at"
  end

  create_table "xerox_copiers", :force => true do |t|
    t.string   "serial_number",                                                              :null => false
    t.integer  "fb_client_id",                                                               :null => false
    t.integer  "user_id",                                                                    :null => false
    t.string   "make"
    t.string   "model"
    t.string   "grouping"
    t.integer  "mono_base",                                           :default => 0,         :null => false
    t.decimal  "mono_overage",          :precision => 6, :scale => 4, :default => 0.0,       :null => false
    t.integer  "color_0_base",                                        :default => 0,         :null => false
    t.decimal  "color_0_overage",       :precision => 6, :scale => 4, :default => 0.0,       :null => false
    t.integer  "mono_color_1_base",                                   :default => 0,         :null => false
    t.decimal  "mono_color_1_overage",  :precision => 6, :scale => 4, :default => 0.0,       :null => false
    t.integer  "color_level_2_base",                                  :default => 0,         :null => false
    t.decimal  "color_level_2_overage", :precision => 6, :scale => 4, :default => 0.0,       :null => false
    t.integer  "color_level_3_base",                                  :default => 0,         :null => false
    t.decimal  "color_level_3_overage", :precision => 6, :scale => 4, :default => 0.0,       :null => false
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
    t.decimal  "base_rate",                                           :default => 0.0,       :null => false
    t.string   "tax_name"
    t.decimal  "tax_rate",              :precision => 6, :scale => 4
    t.string   "sales_tracking_code",                                 :default => "default"
  end

  add_index "xerox_copiers", ["user_id", "serial_number"], :name => "index_xerox_copiers_on_user_id_and_serial_number", :unique => true


  end
end
