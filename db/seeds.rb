User.create! do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.email = "admin@localhost.local"
  user.skip_captcha = true
  user.admin = true
  user.confirmed_at = DateTime.now
end

puts "Created \"admin@localhost.local\" user with password \"password\""