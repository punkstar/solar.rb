module Solar
  module Strategy
    class Basic < Base
      # Battery parameters
      SOC_STEP = 0.25 # kWh per discrete level
      MAX_POWER_KW = 5.0 # kW, max charge/discharge
      SLOT_HOURS = 0.5 # 30 minute slots

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
        @timeslots.each do |timeslot|
          add_projected_remaining_battery_power

          remaining_battery_power = timeslot.projected_remaining_battery_power

          off_peak = (timeslot.from.hour >= 0 && timeslot.from.hour < 6) || timeslot.import_rate < 0.1
          peak = timeslot.from.hour >= 18 && timeslot.from.hour < 19
          before_peak = timeslot.from.hour >= 15 && timeslot.from.hour < 18

          if off_peak
            timeslot.work_mode = WorkMode::CHARGE
          elsif before_peak && remaining_battery_power < 3.0
            timeslot.work_mode = WorkMode::CHARGE
          elsif peak && remaining_battery_power > 1.0
            timeslot.work_mode = WorkMode::DISCHARGE
          end
        end

        super

        @timeslots
      end
    end
  end
end
