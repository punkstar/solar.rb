require_relative "lib/solar"

config = Solar::Config.instance

octopus = Solar::Provider::Octopus.new(
  api_key: config.meter_api_key
)

solar_forecast = Solar::Forecast::SolarForecast.new(
  api_key: config.forecast_api_key
)

open_meteo = Solar::Forecast::OpenMeteo.new

task :consumption do
  octopus.consumption(
    mpan: config.meter_mpan,
    serial: config.meter_serial,
    from: "2025-09-01"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :consumption)
  end
end

task :forecast_solar do
  solar_forecast.forecast(
    panel_groups: config.panel_groups,
    lat: config.installation_lat,
    lon: config.installation_lon
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :forecast_solar)
  end
end

task :weather_forecast do
  open_meteo.forecast(
    lat: config.installation_lat,
    lon: config.installation_lon
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :forecast_weather)
  end
end

task :import_rates do
  octopus.rates(
    product: config.meter_import_product,
    tariff: config.meter_import_tariff,
    direction: "import"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :rates)
  end
end

task :export_rates do
  octopus.rates(
    product: config.meter_export_product,
    tariff: config.meter_export_tariff,
    direction: "export"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :rates)
  end
end

task :agile_export_rates do
  octopus.rates(
    product: "AGILE-OUTGOING-19-05-13",
    tariff: "E-1R-AGILE-OUTGOING-19-05-13-L",
    direction: "export"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :rates)
  end
end

task :agile_import_rates do
  octopus.rates(
    product: "AGILE-24-10-01",
    tariff: "E-1R-AGILE-24-10-01-L",
    direction: "import"
  ).then do |data|
    Solar::Repository.new(database: config.database).save(data, table: :rates)
  end
end