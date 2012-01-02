class EmailTransfer < Transfer

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :dest_email,
    :format => { :with => email_regex }

  def build
    Operation.transaction do
      o = Operation.create!

      ao = AccountOperation.new do |it|
        it.currency = self.currency
        it.amount = self.amount
        it.dest_email = self.dest_email
        it.account = Account.storage_account_for(self.currency)
      end

      o.account_operations << ao

      ao = AccountOperation.new do |it|
        it.currency = self.currency
        it.amount = - self.amount
        it.dest_email = self.dest_email
        it.account_id = self.account_id
        it.active = true
        it.type = "EmailTransfer"
      end

      o.account_operations << ao

      o.save!
    end
  end

  def unactive
    self.active = false
    save!
  end

  def amount_is_valid(trader)
    amount > 0 and trader.balance(self.currency) >= amount
  end

  def cancel
    if !active
      #FIXME ERROR!!
      return
    end
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

  def validate
    Operation.transaction do
      o = Operation.create!

      dest_user = User.where("email = ?", self.dest_email).first

      #FIXME : ERROR ?
      if dest_user.nil?
        return
      end

      ao = AccountOperation.new do |it|
        it.currency = self.currency
        it.amount = - self.amount
        it.account_id = dest_user.id
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
    unactive
  end

end
