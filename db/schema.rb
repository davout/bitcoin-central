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

ActiveRecord::Schema.define(:version => 20110511194431) do

  create_table "invoices", :force => true do |t|
    t.integer  "payee_id"
    t.integer  "payer_id"
    t.decimal  "amount",             :precision => 10, :scale => 0
    t.string   "currency"
    t.string   "merchant_reference"
    t.string   "comment"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "trade_orders", :force => true do |t|
    t.integer  "user_id",                                                                     :null => false
    t.decimal  "amount",                    :precision => 16, :scale => 8, :default => 0.0
    t.decimal  "ppc",                       :precision => 16, :scale => 8, :default => 0.0
    t.string   "currency",                                                                    :null => false
    t.string   "category",                                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                                                   :default => true
    t.boolean  "dark_pool",                                                :default => false, :null => false
    t.boolean  "dark_pool_exclusive_match",                                :default => false, :null => false
  end

  create_table "trades", :force => true do |t|
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
  end

  create_table "transfers", :force => true do |t|
    t.string   "type"
    t.integer  "user_id"
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
  end

  add_index "transfers", ["lr_transaction_id"], :name => "index_transfers_on_lr_transaction_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "account",                                 :null => false
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_address"
    t.string   "salt"
    t.string   "time_zone"
    t.boolean  "admin",                :default => false
    t.string   "secret_token"
    t.string   "encrypted_password",   :default => "",    :null => false
    t.string   "password_salt",        :default => "",    :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
