require "date"
require "time"
require "active_support/all"
require "solar/battery/fox/request/schedule_group"
require "solar/strategy/timeslot"

module Solar
  module Strategy
    class Input
      MIN_SOC = 10
      MAX_SOC = 100
      MAX_CHARGE_POWER = 5000 # watts
      MAX_DISCHARGE_POWER = 5000 # watts

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
          
          Timeslot.new(
            from: from,
            to: from + 30.minutes
          )
        end
      end

      def battery_current_charge
        @battery_data.current_charge
      end

      def battery_usable_capacity
        @config.battery_usable_capacity
      end

      def timeslots
        @timeslots_30m.each do |timeslot|
          timeslot.work_mode = WorkMode::SELF_USE
        end

        add_export_rates
        add_import_rates
        normalize_rates
        add_estimated_usage

        @timeslots_30m
      end

      private

      def add_export_rates
        @timeslots_30m.each do |timeslot|
          export_rate_record = @rates_data.flux_export_rates(time: timeslot.from)
          export_rate = export_rate_record&.dig(:rate) || backup_export_rate(timeslot)

          timeslot.export_rate = export_rate.round(3) if export_rate.present?
        end
      end

      def add_import_rates
        @timeslots_30m.each do |timeslot|
          import_rate_record = @rates_data.agile_import_rates(time: timeslot.from)
          import_rate = import_rate_record&.dig(:rate) || backup_import_rate(timeslot)

          timeslot.import_rate = import_rate.round(3) if import_rate.present?
        end
      end

      def backup_import_rate(timeslot)
        import_rate_record = @rates_data.flux_import_rates(time: timeslot.from)
        import_rate = import_rate_record&.dig(:rate)

        if import_rate.blank?
          if timeslot.from.hour >= 2 && timeslot.from.hour < 5
            return 0.17
          elsif timeslot.from.hour >= 16 && timeslot.from.hour < 19
            return 0.40
          else
            return 0.28
          end
        end

        import_rate.round(3)
      end

      def backup_export_rate(timeslot)
        if timeslot.from.hour >= 2 && timeslot.from.hour < 5
          return 0.0455
        elsif timeslot.from.hour >= 16 && timeslot.from.hour < 19
          return 0.2922
        else
          return 0.1020
        end
      end

      def normalize_rates
        max_export = @timeslots_30m.map { |timeslot| timeslot.export_rate || nil }.compact.max
        max_import = @timeslots_30m.map { |timeslot| timeslot.import_rate || nil }.compact.max

        @timeslots_30m.each do |timeslot|
          next if timeslot.export_rate.blank? || timeslot.import_rate.blank?

          timeslot.normalised_linear_export_rate = (timeslot.export_rate / max_export).round(3)
          timeslot.normalised_linear_import_rate = (timeslot.import_rate / max_import).round(3)
        end
      end

      def add_estimated_usage
        @timeslots_30m.each do |timeslot|
          timeslot.estimated_usage = @config.average_usage[timeslot.from.strftime("%H:%M")]
        end
      end
    end
  end
end
