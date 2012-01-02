class AccountTransfer < Transfer

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :dest_email,
    :format => { :with => email_regex }


  def unactive
    self.active = false
    save!
  end

  def amount_is_valid(trader)
    if amount < 0 or trader.balance(self.currency) < amount
      false
    else
      true
    end
  end

  def cancel
    self.type = "AccountOperation"
    self.save!
    Operation.transaction do
      o = Operation.create!

      ao = AccountOperation.new do |it|
        it.currency = self.currency
        it.amount = - self.amount
        it.account_id = self.account_id
      end

      o.account_operations << ao

      ao = AccountOperation.new do |it|
        it.currency = self.currency
        it.amount = self.amount
        it.account = Account.storage_account_for(self.currency)
      end

      o.account_operations << ao

      o.save!
    end

  end

end
