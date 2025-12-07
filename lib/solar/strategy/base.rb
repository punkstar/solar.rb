module Solar
  module Strategy
    class Base
      STANDING_CHARGE_30_M = 0.66 / 48.0 # p/kWh
      CHARGE_IN_30_M = 2.5 # kwh
      DISCHARGE_IN_30_M = 2.5 # kwh
      
      def initialize(timeslots:, battery_current_charge: 0, battery_usable_capacity: 0)
        @timeslots = timeslots
        @battery_current_charge = battery_current_charge.to_f
        @battery_usable_capacity = battery_usable_capacity.to_f
      end

      def plan
        add_projected_remaining_battery_power
        add_running_cost

        @timeslots
      end

      def grouped_plan
        groups = []
        current_group = nil

        @timeslots.each_with_index do |timeslot, index|          
          # Check if we should start a new group:
          # 1. No current group
          # 2. Work mode changed
          # 3. Crossed midnight (current slot starts at 00:00)
          crossed_midnight = timeslot.from.hour == 0 && timeslot.from.minute == 0
          should_start_new_group = current_group.nil? || 
                                   current_group[:work_mode] != timeslot.work_mode ||
                                   crossed_midnight

          if should_start_new_group
            # Start a new group
            groups << current_group if current_group
            current_group = {
              from: timeslot.from,
              to: timeslot.to,
              work_mode: timeslot.work_mode
            }
          else
            # Extend current group
            current_group[:to] = timeslot.to
          end
        end

        # Add the last group
        groups << current_group if current_group

        schedule_groups = groups.map do |group|
          {
            from: group[:from],
            to: group[:to] - 1.second,
            work_mode: group[:work_mode]
          }

          case group[:work_mode]
          when WorkMode::SELF_USE
            Solar::Battery::Fox::Request::ScheduleGroup.self_use(
              from: group[:from],
              to: group[:to] - 1.second
            )
          when WorkMode::CHARGE
            Solar::Battery::Fox::Request::ScheduleGroup.force_charge(
              from: group[:from],
              to: group[:to] - 1.second
            )
          when WorkMode::DISCHARGE
            Solar::Battery::Fox::Request::ScheduleGroup.force_discharge(
              from: group[:from],
              to: group[:to] - 1.second
            )
          end
        end

        while schedule_groups.count > 8
          current_index = schedule_groups.find_index(&:now?)
          previous_index = current_index - 1
          schedule_groups.delete_at(previous_index)
        end

        schedule_groups
      end

      private

      def add_running_cost
        @timeslots.each_with_index do |timeslot, index|
          previous_timeslot = index > 0 ? @timeslots[index - 1] : nil
          import_rate = timeslot.import_rate
          export_rate = timeslot.export_rate

          battery_full = (@battery_usable_capacity / 1000.0) - timeslot.projected_remaining_battery_power < 0.2
         
          running_cost = if previous_timeslot.present?
            previous_timeslot.running_cost + case timeslot.work_mode
            when WorkMode::SELF_USE
              if timeslot.projected_remaining_battery_power > 0
                STANDING_CHARGE_30_M
              else
                (import_rate * CHARGE_IN_30_M) + STANDING_CHARGE_30_M                
              end
            when WorkMode::CHARGE
              (battery_full ? 0 : import_rate * CHARGE_IN_30_M) + STANDING_CHARGE_30_M
            when WorkMode::DISCHARGE
              (export_rate * DISCHARGE_IN_30_M * -1) + STANDING_CHARGE_30_M
            end
          else
            0
          end

          timeslot.running_cost = running_cost.round(3)
        end
      end

      def add_projected_remaining_battery_power
        @timeslots.each_with_index do |timeslot, index|
          previous_timeslot = index > 0 ? @timeslots[index - 1] : nil
         
          projected_remaining_battery_power = if previous_timeslot.present? 
            case timeslot.work_mode
            when WorkMode::SELF_USE
              previous_timeslot.projected_remaining_battery_power - timeslot.estimated_usage
            when WorkMode::CHARGE
              (previous_timeslot.projected_remaining_battery_power + CHARGE_IN_30_M).clamp(0, @battery_usable_capacity / 1000.0)
            when WorkMode::DISCHARGE
              previous_timeslot.projected_remaining_battery_power - DISCHARGE_IN_30_M
            end
          else
            remaining_battery_power
          end

          timeslot.projected_remaining_battery_power = projected_remaining_battery_power.round(3)
        end
      end

      # kwh
      def remaining_battery_power
        current_charge = @battery_current_charge / 100.0
        usable_capacity = @battery_usable_capacity / 1000.0

        (current_charge * usable_capacity).round(3)
      end
    end
  end
end