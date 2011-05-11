namespace :liberty_reserve do
  desc "Fetches the last 20 transactions and check whether they've been mapped correctly to transfers"
  task :synchronize_transactions => :environment do
    lr = LibertyReserve::Client.new

    # For each currency fetch transactions,
    # for each fetched ID check existence and create if necessary
    ["LREUR", "LRUSD"].each do |c|
      lr.history(c).each do |t|
        Transfer.create_from_lr_transaction_id(t[:lr_transaction_id])
      end
    end
  end
end