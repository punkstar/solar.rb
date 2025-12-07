job_type :rake, "cd :path && ~/.rbenv/bin/rbenv exec bundle exec rake :task --silent :output"

every 5.minutes do
  rake "battery_charge solar_generated_power battery_discharge_power battery_charge_power grid_discharge_power grid_charge_power load_power"
end

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

every 15.minutes do
  rake "strategy:basic"
end