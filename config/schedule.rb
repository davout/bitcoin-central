every 3.minutes do
  rake "bitcoin:synchronize_txns"
end

every 30.minutes do
  rake "bitcoin:backup"
end