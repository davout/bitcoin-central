require 'digest'

class AccountOperation < ActiveRecord::Base
  CURRENCIES = %w{ EUR USD LREUR LRUSD BTC PGAU INR CAD }
  MIN_BTC_CONFIRMATIONS = 4

  default_scope order('`account_operations`.`created_at` DESC')

  belongs_to :operation

  belongs_to :account
    
  after_create :refresh_orders,
    :refresh_account_address
  
  attr_accessible :amount, :currency
   
  validates :amount,
    :presence => true,
    :user_balance => true
  
  validates :currency,
    :presence => true,
    :inclusion => { :in => CURRENCIES}

  validates :account,
    :presence => true

  validates :operation,
    :presence => true

  scope :with_currency, lambda { |currency|
    where("account_operations.currency = ?", currency.to_s.upcase)
  }

  scope :with_confirmations, lambda { |unconfirmed|
    unless unconfirmed
      where("currency <> 'BTC' OR bt_tx_confirmations >= ? OR amount <= 0 OR bt_tx_id IS NULL", MIN_BTC_CONFIRMATIONS)
    end
  }

  def to_label
    "#{I18n.t("activerecord.models.account_operation.one")} n°#{id}"
  end
  
  def refresh_orders
    if account.is_a?(User)
      account.reload.trade_orders.each { |t|
        if t.is_a?(LimitOrder)
          t.inactivate_if_needed!
        else
          if ((t.selling? and currency == "BTC") or (t.buying? and t.currency == currency)) and t.is_a?(MarketOrder) and amount > 0
            t.execute!
          end
        end
      }
    end
  end

  def confirmed?
    bt_tx_id.nil? or (amount < 0) or (bt_tx_confirmations >= MIN_BTC_CONFIRMATIONS)
  end

  def refresh_account_address
    account.generate_new_address if bt_tx_id
  end

  def self.create_from_lr_transaction_id(lr_tx_id)
    t = AccountOperation.find_by_lr_transaction_id(lr_tx_id)

    if t.blank?
      tx = LibertyReserve::Client.instance.get_transaction(lr_tx_id)

      Operation.transaction do
        o = Operation.create!

        o.account_operations << AccountOperation.new do |t|
          tx.keys.each { |key| t.send :"#{key}=", tx[key] }
        end

        o.account_operations << AccountOperation.new do |ao|
          ao.amount = -tx[:amount]
          ao.account = Account.storage_account_for(tx[:currency])
          ao.currency = tx[:currency].to_s.upcase
        end

        o.save!
      end
    end

    t
  end

  def self.synchronize_transactions!
    Account.all.each do |a|
      transactions = Bitcoin::Client.instance.list_transactions(a.id.to_s)

      transactions = transactions.select do |tx|
        ["receive", "generated"].include? tx["category"]
      end

      transactions.each do |tx|
        t = AccountOperation.find(
          :first,
          :conditions => ['bt_tx_id = ? AND account_id = ?', tx["txid"], a.id]
        )

        if t
          t.update_attribute(:bt_tx_confirmations, tx["confirmations"])
        else
          Operation.transaction do
            o = Operation.create!

            o.account_operations << AccountOperation.new do |bt|
              bt.account_id = a.id
              bt.amount = tx["amount"]
              bt.bt_tx_id = tx["txid"]
              bt.bt_tx_confirmations = tx["confirmations"]
              bt.currency = "BTC"
            end

            o.account_operations << AccountOperation.new do |ao|
              ao.account = Account.storage_account_for(:btc)
              ao.amount = -tx["amount"].abs
              ao.currency = "BTC"
            end

            o.save!

            a.generate_new_address
          end
        end
      end
    end
  end

  def self.create_from_lr_post!(confirmation)
    if valid_confirmation?(confirmation)
      transferred =  confirmation[:lr_amnt].to_d
      fee = AccountOperation.fee_for(confirmation[:lr_amnt].to_d)

      # TODO : Add originating account ID ?
      if AccountOperation.find_by_lr_transaction_id(confirmation[:lr_transfer]).blank?
        Operation.transaction do
          operation = Operation.create!

          operation.account_operations << AccountOperation.new do |ao|
            ao.account_id = confirmation[:account_id]
            ao.amount = transferred - fee
            ao.currency = confirmation[:lr_currency]
            ao.lr_transaction_id = confirmation[:lr_transfer]
            ao.lr_transferred_amount = transferred
            ao.lr_merchant_fee = fee
          end

          operation.account_operations << AccountOperation.new do |ao|
            ao.account = Account.storage_account_for(confirmation[:lr_currency].downcase.to_sym)
            ao.amount = fee - transferred
            ao.currency = confirmation[:lr_currency]
          end

          operation.save!
        end
      end
    else
      raise "Confirmation was invalid"
    end
  end

  def self.valid_confirmation?(confirmation)
    confirmation[:secret_word] = BitcoinBank::LibertyReserve['secret_word']
    confirmation[:baggage] = "account_id=#{confirmation[:account_id]}"

    confirmation_array = %w{lr_paidto lr_paidby lr_store lr_amnt lr_transfer lr_merchant_ref baggage lr_currency secret_word}.map do |f|
      confirmation[f.to_sym]
    end

    confirmation_string = confirmation_array.join(":")

    confirmation[:lr_encrypted2] == Digest::SHA2.hexdigest(confirmation_string).upcase
  end

  # Calculates the fee for a Liberty Reserve transfer
  def self.fee_for(amnt)
    raise "Only BigDecimal types should be used" unless amnt.is_a?(BigDecimal)

    max_fee = BigDecimal("2.99")
    min_fee = BigDecimal("0.01")

    fee = (amnt / BigDecimal("100")).round(2, BigDecimal::ROUND_UP)

    [[fee, max_fee].min, min_fee].max
  end
  
  # Should the transaction be highlighted in some way ?
  def unread
    account && (id > account.max_read_tx_id)
  end
  
  def as_json(options={})    
    super(options.merge(
        :only => [
          :id, :address, :email, :amount, :currency, :bt_tx_confirmations, :bt_tx_id, :comment, :created_at
        ],
        :methods => [
          :unread,
          :confirmed?
        ]
      )
    )
  end
end
