job_type :rake, "cd :path && ~/.rbenv/bin/rbenv exec bundle exec rake :task --silent :output"

every 30.minutes do
  rake "consumption"
end

every 1.hour do
  rake "forecast_solar"
end
every 1.hour do
  rake "forecast_weather"
end

every 6.hours do
  rake "import_rates"
end
every 6.hours do
  rake "export_rates"
end
every 6.hours do
  rake "agile_export_rates"
end
every 6.hours do
  rake "agile_import_rates"
end