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
  user.admin                  false
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

Factory.define :trade_order do |trade_order|
end

# This is necessary to prevent the address generation machinery to
# be triggered each time an invoice is saved using its factory
class Factory::Proxy::CreateWithoutAddyGeneration < Factory::Proxy::Build
  def result
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    @instance.stubs(:generate_payment_address)
    @instance.save!
    @instance
  end
end

class Factory
  def self.create_without_addy_generation(name, overrides = {})
    factory_by_name(name).run(Proxy::CreateWithoutAddyGeneration, overrides)
  end
end

Factory.define :invoice, :default_strategy => :create_without_addy_generation do |invoice|
  invoice.amount                      BigDecimal("100.0")
  invoice.authentication_token        "some token"
  invoice.association                 :user
  invoice.sequence(:payment_address)  { |n| "1FXWhKPChEcUnSEoFQ3DGzxKe44MDbat#{n}" }
  invoice.sequence(:callback_url)     { |n| "http://domain.tld/#{n}" }
end

Factory.define(:wire_transfer) do |wire_transfer|
  wire_transfer.association           :account
  wire_transfer.association           :operation
  wire_transfer.amount                -100.0
  wire_transfer.bic                   "foo"
  wire_transfer.iban                  "bar"
  wire_transfer.currency              "EUR"
  wire_transfer.full_name_and_address "foobar"
end