require_relative "lib/solar"

$config = Solar::Config.instance

$octopus = Solar::Provider::Octopus.new(
  api_key: $config.meter_api_key
)

$solar_forecast = Solar::Forecast::SolarForecast.new(
  api_key: $config.forecast_api_key
)

$open_meteo = Solar::Forecast::OpenMeteo.new

$fox = Solar::Battery::Fox.new(
  api_key: $config.battery_api_key,
  serial_number: $config.inverter_serial
)

$telegram = Solar::Notify::Telegram.new(
  token: $config.telegram_token,
  chat_id: $config.telegram_chat_id
)

task :default => [
  :consumption,
  :forecast_solar,
  :forecast_weather,
  :import_rates,
  :export_rates,
  :agile_export_rates,
  :agile_import_rates,
  :battery_charge,
  :solar_generated_power,
  :battery_discharge_power,
  :battery_charge_power,
  :grid_discharge_power,
  :grid_charge_power,
]

task :consumption do
  $octopus.consumption(
    mpan: $config.meter_mpan,
    serial: $config.meter_serial,
    from: "2025-09-01"
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :forecast_solar do
  $solar_forecast.forecast(
    panel_groups: $config.panel_groups,
    lat: $config.installation_lat,
    lon: $config.installation_lon
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :forecast_weather do
  $open_meteo.forecast(
    lat: $config.installation_lat,
    lon: $config.installation_lon
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :import_rates do
  $octopus.rates(
    product: $config.meter_import_product,
    tariff: $config.meter_import_tariff,
    direction: "import"
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :export_rates do
  $octopus.rates(
    product: $config.meter_export_product,
    tariff: $config.meter_export_tariff,
    direction: "export"
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :agile_export_rates do
  $octopus.rates(
    product: "AGILE-OUTGOING-19-05-13",
    tariff: "E-1R-AGILE-OUTGOING-19-05-13-L",
    direction: "export"
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :agile_import_rates do
  $octopus.rates(
    product: "AGILE-24-10-01",
    tariff: "E-1R-AGILE-24-10-01-L",
    direction: "import"
  ).then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :battery_charge do
  $fox.battery_charge.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :solar_generated_power do
  $fox.solar_generated_power.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :battery_discharge_power do
  $fox.battery_discharge_power.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :battery_charge_power do
  $fox.battery_charge_power.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :grid_discharge_power do
  $fox.grid_discharge_power.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :grid_charge_power do
  $fox.grid_charge_power.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :load_power do
  $fox.load_power.then do |data|
    Solar::Repository.new(database: $config.database).save(data)
  end
end

task :work_mode do
  puts $fox.work_mode
end

task :clear_schedule do
  puts $fox.clear_schedule!.inspect
end

task :force_discharge do
  puts $fox.force_discharge!.inspect
end

task :force_charge do
  puts $fox.force_charge!.inspect
end

namespace :strategy do
  def basic_strategy
    strategy_input = Solar::Strategy::Input.new(
      database: $config.database,
      config: $config,
      battery: $fox,
      plan_hours: 24
    )

    strategy = Solar::Strategy::Basic.new(
      timeslots: strategy_input.timeslots,
      battery_current_charge: strategy_input.battery_current_charge,
      battery_usable_capacity: strategy_input.battery_usable_capacity
    )

    strategy.plan.each do |timeslot|
      puts "#{timeslot.from.strftime("%H:%M")} - #{timeslot.to.strftime("%H:%M")}: #{timeslot.work_mode} - import: £#{timeslot.import_rate.present? ? sprintf("%.3f", timeslot.import_rate) : "N/A"}, export: £#{timeslot.export_rate.present? ? sprintf("%.3f", timeslot.export_rate) : "N/A"} cost: £#{sprintf("%.2f", timeslot.running_cost || 0)} solar: #{sprintf("%.2f", timeslot.solar_kwh || 0)} - remaining: #{sprintf("%.2f", timeslot.projected_remaining_battery_power || 0)}kwh"
    end

    grouped_plan = strategy.grouped_plan

    grouped_plan.each do |group|
      puts group.to_s
    end

    grouped_plan
  end

  task :basic => [:battery_charge_power, :battery_charge] do
    grouped_plan = basic_strategy

    result = $fox.set_scheduler!(
      schedule_groups: grouped_plan
    )

    message = "Updated Schedule:\n"
    grouped_plan.each do |group|
      message += "#{group.to_s}"
      message += " (NOW)" if group.now?
      message += "\n"
    end

    puts "Schedule set successfully!"
    puts JSON.pretty_generate(result)

    message += "Schedule set successfully!\n"
    message += JSON.pretty_generate(result)

    $telegram.send_message(message)
  rescue StandardError => e
    $telegram.send_message("Error setting schedule: #{e.message}")
    raise e
  end

  task :basic_preview => [:battery_charge_power, :battery_charge] do
    basic_strategy
  end
end
