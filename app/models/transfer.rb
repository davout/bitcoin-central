class Transfer < AccountOperation
  attr_accessor :skip_min_amount
  
  default_scope order('created_at DESC')

  after_create :execute

  validates :amount,
    :numericality => true,
    :user_balance => true,
    :minimal_amount => true
  
  def type_name
    type.gsub(/Transfer/, "").underscore.gsub(/\_/, " ").titleize
  end

  def withdrawal!
    self.amount = -(amount.abs) if amount
    self
  end

  # Placeholder
  def confirmed?
    true
  end

  def execute
  end

  # TODO : This looks pretty messy
  def self.from_params(payee, params)
    transfer = Transfer.new

    if payee
      payee = payee.strip

      if payee =~ /^BC-[A-Z][0-9]{6}$/
        transfer = InternalTransfer.new(params)
        transfer.payee = User.find_by_account(payee)
      elsif (params[:currency].downcase == "btc") or Bitcoin::Util.valid_bitcoin_address?(payee)
        transfer = BitcoinTransfer.new(params)
        transfer.address = payee
      elsif (params[:currency].downcase =~ /^lr.+$/) and (payee =~ /^U[0-9]{7}$/)
        transfer = LibertyReserveTransfer.new(params)
        transfer.lr_account_id = payee
      end

      transfer.withdrawal!
    end
  end

  def self.create_from_lr_transaction_id(lr_tx_id)
    # We create a plain Transfer since we don't want
    # anything to be executed after creation
    t = Transfer.find_by_lr_transaction_id(lr_tx_id) 
    
    if t.blank?
      tx = LibertyReserve::Client.instance.get_transaction(lr_tx_id)
      
      Transfer.transaction do 
        o = Operation.create!
        
        o.account_operations << Transfer.new do |t|
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
end