# Admin.create! do |user|
#   user.password = "password"
#   user.password_confirmation = "password"
#   user.email = "admin@localhost.local"
#   user.skip_captcha = true
#   user.confirmed_at = DateTime.now
# end

# puts "Created \"admin@localhost.local\" user with password \"password\""
#encoding : utf-8

operation = Operation.create
%w{test1@bitwin.co test2@bitwin.co test3@bitwin.co}.each do |email|
  AccountOperation::CURRENCIES.each do |currency|
    ap = AccountOperation.create({
                  amount: 100000000,
                  currency: currency
      })
    ap.account = User.find_by_email(email)
    ap.operation = operation
    if ap.save!
      puts '充值成功！'
    end
  end
end
