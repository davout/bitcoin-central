unless BitcoinBank.const_defined? :LibertyReserve
  BitcoinBank.const_set(:LibertyReserve, YAML::load(File.open(File.join(Rails.root, "config", "liberty_reserve.yml")))[Rails.env])
end