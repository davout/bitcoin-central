class AccountTransfer < Transfer


  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :dest_email,
    :format => { :with => email_regex }

  def unactive
    self.active = false
    save!
  end


end
