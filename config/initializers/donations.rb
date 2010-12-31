unless BitcoinBank.const_defined? :Donations
  BitcoinBank.const_set(:Donations, YAML::load(File.open(File.join(Rails.root, "config", "bitcoin.yml")))[Rails.env]['donations'])
end