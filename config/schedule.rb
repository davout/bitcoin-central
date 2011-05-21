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
  rake "bitcoin:backup"
end

every 1.day do
  rake "bitcoin:prune_old_pending_invoices"
end