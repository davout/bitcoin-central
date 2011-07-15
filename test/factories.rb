Factory.define :announcement do |a|
  a.content 'lorem ipsum dolor'
  a.active  true
end

Factory.define :user do |user|
  user.name                   { |u| "BC-U#{(rand * 10 ** 6).to_i}" }
  user.email                  { |u| "#{u.name}@domain.tld" }
  user.password               "password"
  user.password_confirmation  { |u| u.password }
  user.skip_captcha           true
  user.confirmed_at           DateTime.now
end

Factory.define :yubikey do |yubikey|
  yubikey.sequence(:otp) { |n| "#{n}somerandomprettylongotp" }
  yubikey.association    :user
end

Factory.define :operation do
end

Factory.define :account do |account|
  account.sequence(:name) { |n| "account#{n}" }
end

Factory.define :account_operation do |account_operation|
  account_operation.association :account
end

Factory.define :transfer do |transfer|
  transfer.association      :account
  transfer.association      :operation
  transfer.currency         "EUR"
  transfer.skip_min_amount  false
end

Factory.define :trade_order do |trade_order|
end
