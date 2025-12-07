module Solar
  module Battery
    class Fox
      module Request
        class DeviceSchedulerEnable
          def initialize(serial_number:, schedule_groups:)
            @serial_number = serial_number
            @schedule_groups = schedule_groups
          end

          def to_h
            {
              deviceSN: @serial_number,
              groups: @schedule_groups.map(&:to_h)
            }
          end
        end
      end
    end
  end
end