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
  user.merchant               false
  user.sequence(:bitcoin_address)     { |n| "1FXWhKPChEcUnSEoFQ3DGzxKe44MDbat#{n}" }
  user.com                    "0"
end

Factory.define :manager do |user|
  user.name                   { |u| "BC-U#{(rand * 10 ** 6).to_i}" }
  user.email                  { |u| "#{u.name}@domain.tld" }
  user.password               "password"
  user.password_confirmation  { |u| u.password }
  user.skip_captcha           true
  user.confirmed_at           DateTime.now
  user.merchant               false
  user.sequence(:bitcoin_address)     { |n| "1FXWhKPChEcUnSEoFQ3DGzxKe44MDbat#{n}" }
end

Factory.define :admin do |user|
  user.name                   { |u| "BC-U#{(rand * 10 ** 6).to_i}" }
  user.email                  { |u| "#{u.name}@domain.tld" }
  user.password               "password"
  user.password_confirmation  { |u| u.password }
  user.skip_captcha           true
  user.confirmed_at           DateTime.now
  user.merchant               false
  user.sequence(:bitcoin_address)     { |n| "1FXWhKPChEcUnSEoFQ3DGzxKe44MDbat#{n}" }
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
  transfer.bt_tx_id         nil
end

Factory.define :market_order do |market_order|
end

Factory.define :limit_order do |limit_order|
end

Factory.define :invoice do |invoice|
  invoice.amount                      BigDecimal("100.0")
  invoice.authentication_token        "some token"
  invoice.association                 :user
  invoice.sequence(:payment_address)  { |n| "1FXWhKPChEcUnSEoFQ3DGzxKe44MDbat#{n}" }
  invoice.sequence(:callback_url)     { |n| "http://domain.tld/#{n}" }
  
  invoice.to_create { |i|
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    i.stubs(:generate_payment_address)
    i.save!
  }
end

Factory.define(:wire_transfer) do |wire_transfer|
  wire_transfer.association           :account
  wire_transfer.association           :operation
  wire_transfer.association           :bank_account
  wire_transfer.amount                -100.0
  wire_transfer.currency              "EUR"
end

Factory.define :bitcoin_transfer do |transfer|
  transfer.association          :account
  transfer.association          :operation
  transfer.amount               BigDecimal("-20")
  transfer.sequence(:address)   { |n| "1FXWhKPChEcUnSEoFQ3DGzxKe44MDbat#{n}" }  
  transfer.currency             "BTC"
  transfer.bt_tx_id             nil
end

Factory.define(:bank_account) do |bank_account|
  bank_account.association    :user
  bank_account.bic            "SOGEFRPP"
  bank_account.iban           "FR1420041010050500013M02606"
  bank_account.account_holder "foo"
end
