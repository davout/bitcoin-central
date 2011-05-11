every 3.minutes do
  rake "bitcoin:synchronize_transactions"
end

every 10.minutes do
  rake "liberty_reserve:synchronize_transactions"
end

every 30.minutes do
  rake "bitcoin:backup"
end