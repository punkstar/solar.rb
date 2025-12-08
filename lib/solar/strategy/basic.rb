module Solar
  module Strategy
    class Basic < Base
      PEAK_EXPORT_RATE = 0.2922
      
      def plan
        median_price = @timeslots.map { |timeslot| timeslot.import_rate }.sort[(@timeslots.count / 2).floor]

        @timeslots.each do |timeslot|
          add_projected_remaining_battery_power

          remaining_battery_power_kwh = timeslot.projected_remaining_battery_power
          battery_full = battery_usable_capacity_kwh - remaining_battery_power_kwh < 0.2

          off_peak = (timeslot.from.hour >= 2 && timeslot.from.hour <= 5) || timeslot.import_rate < 0.1
          peak = timeslot.from.hour >= 16 && timeslot.from.hour < 19
          before_peak = timeslot.from.hour >= 12 && timeslot.from.hour < 16

          if off_peak
            timeslot.work_mode = WorkMode::CHARGE
          elsif before_peak && remaining_battery_power_kwh < 6
            timeslot.work_mode = WorkMode::CHARGE
          elsif before_peak && timeslot.import_rate < PEAK_EXPORT_RATE && !battery_full
            timeslot.work_mode = WorkMode::CHARGE
          elsif peak && remaining_battery_power_kwh > 4
            timeslot.work_mode = WorkMode::DISCHARGE
          elsif timeslot.import_rate < median_price && remaining_battery_power_kwh < 6
            timeslot.work_mode = WorkMode::CHARGE
          end
        end

        super

        @timeslots
      end
    end
  end
end
