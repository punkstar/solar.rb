require_relative "lib/solar"

config = Solar::Config.instance

octopus = Solar::Provider::Octopus.new(
  api_key: config.meter_api_key
)

solar_forecast = Solar::Forecast::SolarForecast.new(
  api_key: config.forecast_api_key
)

open_meteo = Solar::Forecast::OpenMeteo.new

fox = Solar::Battery::Fox.new(
  api_key: config.battery_api_key,
  serial_number: config.inverter_serial
)

task :consumption do
  octopus.consumption(
    mpan: config.meter_mpan,
    serial: config.meter_serial,
    from: "2025-09-01"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :forecast_solar do
  solar_forecast.forecast(
    panel_groups: config.panel_groups,
    lat: config.installation_lat,
    lon: config.installation_lon
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :weather_forecast do
  open_meteo.forecast(
    lat: config.installation_lat,
    lon: config.installation_lon
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :import_rates do
  octopus.rates(
    product: config.meter_import_product,
    tariff: config.meter_import_tariff,
    direction: "import"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :export_rates do
  octopus.rates(
    product: config.meter_export_product,
    tariff: config.meter_export_tariff,
    direction: "export"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :agile_export_rates do
  octopus.rates(
    product: "AGILE-OUTGOING-19-05-13",
    tariff: "E-1R-AGILE-OUTGOING-19-05-13-L",
    direction: "export"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :agile_import_rates do
  octopus.rates(
    product: "AGILE-24-10-01",
    tariff: "E-1R-AGILE-24-10-01-L",
    direction: "import"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :battery_charge do
  fox.battery_charge.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :solar_generated_power do
  fox.solar_generated_power.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :battery_discharge_power do
  fox.battery_discharge_power.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :battery_charge_power do
  fox.battery_charge_power.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :grid_discharge_power do
  fox.grid_discharge_power.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :grid_charge_power do
  fox.grid_charge_power.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :load_power do
  fox.load_power.then do |data|
    Solar::Repository.new(database: config.database).save(data)
  end
end

task :work_mode do
  puts fox.work_mode
end

task :clear_schedule do
  puts fox.clear_schedule!.inspect
end

task :force_discharge do
  puts fox.force_discharge!.inspect
end

task :force_charge do
  puts fox.force_charge!.inspect
end
