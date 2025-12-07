#!/usr/bin/env ruby

require "json"
require "date"
require_relative "../lib/solar"

# Get serial number from config
config = Solar::Config.instance

# Get today's date for creating DateTime objects
today = Date.today

# Create schedule groups from the JSON data
schedule_groups = [
  # Item 1: SelfUse, disabled, 00:00-00:59
  Solar::Battery::Fox::Request::ScheduleGroup.self_use(
    from: DateTime.new(today.year, today.month, today.day, 0, 0, 0),
    to: DateTime.new(today.year, today.month, today.day, 0, 59, 0)
  ),
  
  # Item 2: ForceCharge, enabled, 01:00-06:29
  Solar::Battery::Fox::Request::ScheduleGroup.force_charge(
    from: DateTime.new(today.year, today.month, today.day, 1, 0, 0),
    to: DateTime.new(today.year, today.month, today.day, 6, 29, 0)
  ),
  
  # Item 3: SelfUse, disabled, 06:30-17:59
  Solar::Battery::Fox::Request::ScheduleGroup.self_use(
    from: DateTime.new(today.year, today.month, today.day, 6, 30, 0),
    to: DateTime.new(today.year, today.month, today.day, 17, 59, 0)
  ),
  
  # Item 4: ForceDischarge, enabled, 18:00-18:59 (custom minsocongrid: 30, fdsoc: 30)
  Solar::Battery::Fox::Request::ScheduleGroup.force_discharge(
    from: DateTime.new(today.year, today.month, today.day, 18, 0, 0),
    to: DateTime.new(today.year, today.month, today.day, 18, 59, 0),
    until_soc: 30
  ),
  
  # Item 5: SelfUse, enabled, 19:00-23:29
  Solar::Battery::Fox::Request::ScheduleGroup.self_use(
    from: DateTime.new(today.year, today.month, today.day, 19, 0, 0),
    to: DateTime.new(today.year, today.month, today.day, 23, 29, 0)
  ),
  
  # Item 6: ForceCharge, enabled, 23:30-23:59
  Solar::Battery::Fox::Request::ScheduleGroup.force_charge(
    from: DateTime.new(today.year, today.month, today.day, 23, 30, 0),
    to: DateTime.new(today.year, today.month, today.day, 23, 59, 0)
  )
]

# Send the request
fox = Solar::Battery::Fox.new(
  api_key: config.battery_api_key,
  serial_number: config.inverter_serial
)

result = fox.set_scheduler!(
  schedule_groups: schedule_groups
)

puts "Schedule set successfully!"
puts JSON.pretty_generate(result)
