namespace :transfers do
  desc "Remove the AccountTransfers that are not accepted within 3 days"
  task :delete_old_transfers => :environment do
    AccountTransfer.
      where("active = true").
      where("created_at < ?", DateTime.now.advance(:days => - 3)).
      each do |at|
        at.cancel
      end
  end
end
