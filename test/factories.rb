Factory.define :announcement do |a|
  a.content 'lorem ipsum dolor'
  a.active  true
end

Factory.define :user do |user|
  user.account                { |u| "BC-U#{(rand * 10 ** 6).to_i}" }
  user.email                  { |u| "#{u.account}@domain.tld" }
  user.password               "password"
  user.password_confirmation  { |u| u.password }
  user.skip_captcha           true
  user.confirmed_at           DateTime.now
end

Factory.define :yubikey do |yubikey|
  yubikey.sequence(:otp) { |n| "#{n}somerandomprettylongotp" }
  yubikey.association    :user
end
