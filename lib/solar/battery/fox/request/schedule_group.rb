module Solar
  module Battery
    class Fox
      module Request
        class ScheduleGroup
          module WorkMode
            FORCE_CHARGE = "ForceCharge"
            FORCE_DISCHARGE = "ForceDischarge"
            SELF_USE = "SelfUse"
          end

          SOC_MIN = 10

          class << self
            # @param from [DateTime]
            # @param to [DateTime]
            def force_charge(from:, to:)
              new(
                enable: true,
                start_hour: from.strftime("%H").to_i,
                start_minute: from.strftime("%M").to_i,
                end_hour: to.strftime("%H").to_i,
                end_minute: to.strftime("%M").to_i,
                work_mode: WorkMode::FORCE_CHARGE,
                min_soc_on_grid: SOC_MIN,
                fd_soc: 100,
                fd_pwr: 5000,
                max_soc: 100
              )
            end

            def force_discharge(from:, to:, until_soc: SOC_MIN)
              new(
                enable: true,
                start_hour: from.strftime("%H").to_i,
                start_minute: from.strftime("%M").to_i,
                end_hour: to.strftime("%H").to_i,
                end_minute: to.strftime("%M").to_i,
                work_mode: WorkMode::FORCE_DISCHARGE,
                min_soc_on_grid: until_soc,
                fd_soc: until_soc,
                fd_pwr: 5000,
                max_soc: 100
              )
            end

            def self_use(from:, to:)
              new(
                enable: true,
                start_hour: from.strftime("%H").to_i,
                start_minute: from.strftime("%M").to_i,
                end_hour: to.strftime("%H").to_i,
                end_minute: to.strftime("%M").to_i,
                work_mode: WorkMode::SELF_USE,
                min_soc_on_grid: SOC_MIN,
                fd_soc: SOC_MIN,
                fd_pwr: 0,
                max_soc: 100
              )
            end
          end

          attr_reader :enable, :start_hour, :start_minute, :end_hour, :end_minute,
                      :work_mode, :min_soc_on_grid, :fd_soc, :fd_pwr, :max_soc,
                      :max_soc_unit, :soc_unit, :pwr_unit, :min_soc_unit

          def initialize(
            enable:,
            start_hour:,
            start_minute:,
            end_hour:,
            end_minute:,
            work_mode:,
            min_soc_on_grid:,
            fd_soc:,
            fd_pwr:,
            max_soc:,
            max_soc_unit: "%",
            soc_unit: "%",
            pwr_unit: "W",
            min_soc_unit: "%"
          )
            @enable = enable
            @start_hour = start_hour
            @start_minute = start_minute
            @end_hour = end_hour
            @end_minute = end_minute
            @work_mode = work_mode
            @min_soc_on_grid = min_soc_on_grid
            @fd_soc = fd_soc
            @fd_pwr = fd_pwr
            @max_soc = max_soc
            @max_soc_unit = max_soc_unit
            @soc_unit = soc_unit
            @pwr_unit = pwr_unit
            @min_soc_unit = min_soc_unit
          end

          def to_h
            {
              enable: @enable ? 1 : 0,
              startMinute: @start_minute,
              startHour: @start_hour,
              endHour: @end_hour,
              endMinute: @end_minute,
              workMode: @work_mode,
              minSocOnGrid: @min_soc_on_grid,
              fdSoc: @fd_soc,
              maxSoc: @max_soc,
              fdPwr: @fd_pwr
            }
          end
        end
      end
    end
  end
end