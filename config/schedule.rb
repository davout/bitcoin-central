job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

every 3.minutes do
  rake "bitcoin:synchronize_transactions"
end

every 5.minutes do
  rake "bitcoin:process_pending_invoices"
end

every 10.minutes do
  rake "liberty_reserve:synchronize_transactions"
end

every 30.minutes do
  rake "bitcoin:backup_wallet"
end

every 1.day, :at => '5:30 am' do
  rake "bitcoin:backup_db"
end

every 1.day do
  rake "bitcoin:prune_old_pending_invoices"
end