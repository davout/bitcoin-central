class AccountTransfer < Transfer


  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :dest_email,
    :format => { :with => email_regex }


  def unactive
    self.active = false
    save!
  end

  def amount_is_valid(trader)
    puts trader.balance(:currency)
    puts amount
    if amount < 0 or trader.balance(:currency) < amount
      false
    else
      true
    end
  end

end
