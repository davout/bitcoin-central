namespace :bitcoin do
  desc "Synchronizes the transactions in the client with the transactions stored in the database"
  task :synchronize_txns => :environment do
    BitcoinTransfer.synchronize_transactions!
  end
end