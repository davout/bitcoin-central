module Bitcoin
  module Util
    def self.valid_bitcoin_address?(address)
      # We don't want leading/trailing spaces to pollute addresses
      (address == address.strip) and Bitcoin::Client.instance.validate_address(address)['isvalid']
    end

    def self.my_bitcoin_address?(address)
      Bitcoin::Client.instance.validate_address(address)['ismine']
    end

    def self.get_account(address)
      Bitcoin::Client.instance.get_account(address)
    end
  end
end