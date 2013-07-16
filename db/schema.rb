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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111205110307) do

  create_table "account_operations", :force => true do |t|
    t.string   "type"
    t.integer  "account_id"
    t.string   "address"
    t.decimal  "amount",                :precision => 16, :scale => 8, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.string   "lr_transaction_id"
    t.decimal  "lr_transferred_amount", :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "lr_merchant_fee",       :precision => 16, :scale => 8, :default => 0.0
    t.string   "bt_tx_id"
    t.string   "bt_tx_from"
    t.integer  "bt_tx_confirmations",                                  :default => 0
    t.string   "lr_account_id"
    t.integer  "payee_id"
    t.string   "email"
    t.string   "px_tx_id"
    t.string   "px_payer"
    t.decimal  "px_fee",                :precision => 16, :scale => 8, :default => 0.0
    t.string   "comment"
    t.integer  "operation_id"
    t.string   "state"
    t.integer  "bank_account_id"
  end

  add_index "account_operations", ["lr_transaction_id"], :name => "index_transfers_on_lr_transaction_id", :unique => true

  create_table "accounts", :force => true do |t|
    t.string   "name",                                                                     :null => false
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bitcoin_address"
    t.string   "salt"
    t.string   "time_zone"
    t.string   "secret_token"
    t.string   "encrypted_password",                                    :default => "",    :null => false
    t.string   "password_salt",                                         :default => "",    :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.boolean  "merchant",                                              :default => false
    t.string   "ga_otp_secret"
    t.boolean  "require_ga_otp",                                        :default => false
    t.datetime "last_address_refresh"
    t.boolean  "require_yk_otp",                                        :default => false
    t.integer  "parent_id"
    t.string   "type"
    t.string   "full_name"
    t.text     "address"
    t.boolean  "notify_on_trade",                                       :default => true
    t.integer  "last_notified_trade_id",                                :default => 0,     :null => false
    t.integer  "max_read_tx_id",                                        :default => 0,     :null => false
    t.decimal  "commission_rate",        :precision => 16, :scale => 8
  end

  add_index "accounts", ["email"], :name => "index_users_on_email", :unique => true

  create_table "announcements", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.string   "bic",            :null => false
    t.string   "iban",           :null => false
    t.text     "account_holder"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "ticket_id"
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", :force => true do |t|
    t.string   "code",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.string   "state",                                                                :null => false
    t.integer  "user_id",                                                              :null => false
    t.decimal  "amount",               :precision => 16, :scale => 8, :default => 0.0, :null => false
    t.string   "payment_address",                                                      :null => false
    t.string   "callback_url",                                                         :null => false
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reference",                                                            :null => false
    t.string   "merchant_reference"
    t.string   "merchant_memo"
    t.string   "authentication_token",                                                 :null => false
    t.string   "item_url"
  end

  add_index "invoices", ["authentication_token"], :name => "index_invoices_on_authentication_token", :unique => true
  add_index "invoices", ["payment_address"], :name => "index_invoices_on_payment_address", :unique => true
  add_index "invoices", ["reference"], :name => "index_invoices_on_reference", :unique => true

  create_table "operations", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "sale_order_id"
    t.decimal  "traded_btc",        :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "traded_currency",   :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "ppc",               :precision => 16, :scale => 8, :default => 0.0
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.string   "type"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "static_pages", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "locale"
    t.text     "contents"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tickets", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trade_orders", :force => true do |t|
    t.integer  "user_id",                                                                     :null => false
    t.decimal  "amount",                    :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "ppc",                       :precision => 16, :scale => 8
    t.string   "currency",                                                                    :null => false
    t.string   "category",                                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                                                   :default => true
    t.boolean  "dark_pool",                                                :default => false, :null => false
    t.boolean  "dark_pool_exclusive_match",                                :default => false, :null => false
    t.string   "type"
  end

  create_table "used_currencies", :force => true do |t|
    t.integer  "account_id",                                                      :null => false
    t.integer  "currency_id",                                                     :null => false
    t.boolean  "active",                                       :default => true
    t.decimal  "daily_limit",   :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "monthly_limit", :precision => 16, :scale => 8, :default => 0.0
    t.boolean  "management",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "yubikeys", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.string   "key_id",                       :null => false
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
