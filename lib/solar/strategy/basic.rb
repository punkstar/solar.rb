require "date"
require "time"
require "active_support/all"
require "solar/battery/fox/request/schedule_group"

module Solar
  module Strategy
    class Basic
      # Battery constraints (can be made configurable later)
      MIN_SOC = 10
      MAX_SOC = 100
      MAX_CHARGE_POWER = 5000 # watts
      MAX_DISCHARGE_POWER = 5000 # watts

      # Decision thresholds
      CHARGE_THRESHOLD = -0.05 # p/kWh - charge when import is this much cheaper than export
      DISCHARGE_THRESHOLD = 0.10 # p/kWh - discharge when export is this much more than import
      HIGH_SOLAR_THRESHOLD = 2000 # watts - use self-use mode when solar generation exceeds this

      CHARGE_IN_30_M = 1 # kwh
      DISCHARGE_IN_30_M = 1 # kwh
      STANDING_CHARGE_30_M = 0.66 / 48.0 # p/kWh

      module WorkMode
        CHARGE = "charge"
        DISCHARGE = "discharge"
        SELF_USE = "self_use"
      end

      def initialize(database:, config:, battery:, plan_hours: 18)
        @database = database
        @config = config
        @battery = battery
        @battery_data = BatteryData.new(database: database)
        @rates_data = RatesData.new(database: database)
        @forecast_data = ForecastData.new(database: database)


        @now = DateTime.now
        @rounded_now = DateTime.new(@now.year, @now.month, @now.day, @now.hour, @now.minute > 30 ? 30 : 0, 0)

        @timeslots_30m = (plan_hours * 2).times.map do |i|
          from = @rounded_now + (i * 30.minutes)
          
          {
            from: from,
            to: from + 30.minutes
          }
        end
      end

      # kwh
      def remaining_battery_power
        current_charge = @battery_data.current_charge / 100.0 || 0.0
        usable_capacity = @config.battery_usable_capacity / 1000.0

        (current_charge * usable_capacity).round(3)
      end

      def plan
        @timeslots_30m.each do |timeslot|
          timeslot[:work_mode] = WorkMode::SELF_USE
        end

        add_export_rates
        add_import_rates
        normalize_rates
        add_estimated_usage

        apply_best_plan

        add_projected_remaining_battery_power
        add_running_cost

        @timeslots_30m
      end

      private

      def add_export_rates
        @timeslots_30m.each do |timeslot|
          export_rate_record = @rates_data.flux_export_rates(time: timeslot[:from])
          export_rate = export_rate_record&.dig(:rate) || backup_export_rate(timeslot)

          timeslot[:export_rate] = export_rate.round(3) if export_rate.present?
        end
      end

      def add_import_rates
        @timeslots_30m.each do |timeslot|
          import_rate_record = @rates_data.agile_import_rates(time: timeslot[:from])
          import_rate = import_rate_record&.dig(:rate) || backup_import_rate(timeslot)

          timeslot[:import_rate] = import_rate.round(3) if import_rate.present?
        end
      end

      def backup_import_rate(timeslot)
        import_rate_record = @rates_data.flux_import_rates(time: timeslot[:from])
        import_rate = import_rate_record&.dig(:rate)

        if import_rate.blank?
          if timeslot[:from].hour >= 2 && timeslot[:from].hour < 5
            return 0.17
          elsif timeslot[:from].hour >= 16 && timeslot[:from].hour < 19
            return 0.40
          else
            return 0.28
          end
        end

        import_rate.round(3)
      end

      def backup_export_rate(timeslot)
        if timeslot[:from].hour >= 2 && timeslot[:from].hour < 5
          return 0.0455
        elsif timeslot[:from].hour >= 16 && timeslot[:from].hour < 19
          return 0.2922
        else
          return 0.1020
        end
      end

      def normalize_rates
        max_export = @timeslots_30m.map { |timeslot| timeslot.dig(:export_rate) || nil }.compact.max
        max_import = @timeslots_30m.map { |timeslot| timeslot.dig(:import_rate) || nil }.compact.max

        @timeslots_30m.each do |timeslot|
          next if timeslot[:export_rate].blank? || timeslot[:import_rate].blank?

          timeslot[:normalised_linear_export_rate] = (timeslot[:export_rate] / max_export).round(3)
          timeslot[:normalised_linear_import_rate] = (timeslot[:import_rate] / max_import).round(3)
        end
      end

      def add_estimated_usage
        average_usage = {
          "00:00" => 0.25,
          "00:30" => 0.25,
          "01:00" => 0.25,
          "01:30" => 0.25,
          "02:00" => 0.75,
          "02:30" => 0.75,
          "03:00" => 0.75,
          "03:30" => 0.25,
          "04:00" => 0.25,
          "04:30" => 0.25,
          "05:00" => 0.25,
          "05:30" => 0.25,
          "06:00" => 0.25,
          "06:30" => 0.25,
          "07:00" => 0.25,
          "07:30" => 0.25,
          "08:00" => 0.25,
          "08:30" => 0.25,
          "09:00" => 0.25,
          "09:30" => 0.25,
          "10:00" => 0.25,
          "10:30" => 0.25,
          "11:00" => 0.5,
          "11:30" => 0.5,
          "12:00" => 0.5,
          "12:30" => 0.5,
          "13:00" => 0.25,
          "13:30" => 0.25,
          "14:00" => 0.25,
          "14:30" => 0.25,
          "15:00" => 0.25,
          "15:30" => 0.25,
          "16:00" => 0.25,
          "16:30" => 0.25,
          "17:00" => 0.25,
          "17:30" => 0.75,
          "18:00" => 0.75,
          "18:30" => 0.75,
          "19:00" => 0.25,
          "19:30" => 0.25,
          "20:00" => 0.25,
          "20:30" => 0.25,
          "21:00" => 0.25,
          "21:30" => 0.25,
          "22:00" => 0.25,
          "22:30" => 0.25,
          "23:00" => 0.25,
          "23:30" => 0.25,
        }

        @timeslots_30m.each do |timeslot|
          timeslot[:estimated_usage] = average_usage[timeslot[:from].strftime("%H:%M")]
        end
      end

      def add_running_cost
        @timeslots_30m.each_with_index do |timeslot, index|
          previous_timeslot = index > 0 ? @timeslots_30m[index - 1] : nil
          import_rate = timeslot[:import_rate]
          export_rate = timeslot[:export_rate]
         
          running_cost = if previous_timeslot.present?
            previous_timeslot[:running_cost] + case timeslot[:work_mode]
            when WorkMode::SELF_USE
              if timeslot[:projected_remaining_battery_power] > 0
                STANDING_CHARGE_30_M
              else
                (import_rate * CHARGE_IN_30_M) + STANDING_CHARGE_30_M                
              end
            when WorkMode::CHARGE
              (import_rate * CHARGE_IN_30_M) + STANDING_CHARGE_30_M
            when WorkMode::DISCHARGE
              (export_rate * DISCHARGE_IN_30_M) + STANDING_CHARGE_30_M * -1
            end
          else
            0
          end

          timeslot[:running_cost] = running_cost.round(3)
        end
      end

      def add_projected_remaining_battery_power
        @timeslots_30m.each_with_index do |timeslot, index|
          previous_timeslot = index > 0 ? @timeslots_30m[index - 1] : nil
         
          projected_remaining_battery_power = if previous_timeslot.present? 
            case timeslot[:work_mode]
            when WorkMode::SELF_USE
              previous_timeslot[:projected_remaining_battery_power] - timeslot[:estimated_usage]
            when WorkMode::CHARGE
              (previous_timeslot[:projected_remaining_battery_power] + CHARGE_IN_30_M).clamp(0, @config.battery_usable_capacity / 1000.0)
            when WorkMode::DISCHARGE
              previous_timeslot[:projected_remaining_battery_power] - DISCHARGE_IN_30_M
            end
          else
            remaining_battery_power
          end

          timeslot[:projected_remaining_battery_power] = projected_remaining_battery_power.round(3)
        end
      end

      def apply_best_plan
        
      end
    end
  end
end
