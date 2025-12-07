module Solar
  module Strategy
    class Basic < Base
      # Battery parameters
      SOC_STEP = 0.25 # kWh per discrete level
      MAX_POWER_KW = 5.0 # kW, max charge/discharge
      SLOT_HOURS = 0.5 # 30 minute slots

      PEAK_EXPORT_RATE = 0.2922

      module Action
        CHARGE = "charge"
        DISCHARGE = "discharge"
        IDLE = "idle"
      end

      SlotPlan = Struct.new(
        :soc_start_kwh,
        :soc_end_kwh,
        :p_batt_kw,
        :action,
        :grid_import_kwh,
        :grid_export_kwh,
        :load_from_batt_kwh,
        :load_from_solar_kwh,
        :load_from_grid_kwh,
        :profit
      )

      def plan
        median_price = @timeslots.map { |timeslot| timeslot.import_rate }.sort[(@timeslots.count / 2).floor]

        @timeslots.each do |timeslot|
          add_projected_remaining_battery_power

          remaining_battery_power = timeslot.projected_remaining_battery_power
          battery_full = battery_usable_capacity_kwh - remaining_battery_power < 0.2

          off_peak = (timeslot.from.hour >= 2 && timeslot.from.hour <= 5) || timeslot.import_rate < 0.1
          peak = timeslot.from.hour >= 16 && timeslot.from.hour < 19
          before_peak = timeslot.from.hour >= 12 && timeslot.from.hour < 16

          if off_peak
            timeslot.work_mode = WorkMode::CHARGE
          elsif before_peak && remaining_battery_power < 6
            timeslot.work_mode = WorkMode::CHARGE
          elsif before_peak && timeslot.import_rate < PEAK_EXPORT_RATE && !battery_full
            timeslot.work_mode = WorkMode::CHARGE
          elsif peak && remaining_battery_power > 4
            timeslot.work_mode = WorkMode::DISCHARGE
          elsif timeslot.import_rate < median_price && remaining_battery_power < 6
            timeslot.work_mode = WorkMode::CHARGE
          end
        end

        super

        @timeslots
      end
    end
  end
end
