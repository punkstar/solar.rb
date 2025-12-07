module Solar
  module Strategy
    class Timeslot
      attr_accessor :from,
                    :to,
                    :work_mode,
                    :export_rate,
                    :import_rate,
                    :normalised_linear_export_rate,
                    :normalised_linear_import_rate,
                    :estimated_usage,
                    :projected_remaining_battery_power,
                    :running_cost,
                    :solar_kwh,
                    :soc_start_kwh,
                    :soc_end_kwh,
                    :p_batt_kw,
                    :grid_import_kwh,
                    :grid_export_kwh,
                    :profit

      def initialize(from:, to:, work_mode: nil, export_rate: nil, import_rate: nil,
                     normalised_linear_export_rate: nil, normalised_linear_import_rate: nil,
                     estimated_usage: nil, projected_remaining_battery_power: nil,
                     running_cost: nil, solar_kwh: nil, soc_start_kwh: nil, soc_end_kwh: nil,
                     p_batt_kw: nil, grid_import_kwh: nil, grid_export_kwh: nil, profit: nil)
        @from = from
        @to = to
        @work_mode = work_mode
        @export_rate = export_rate
        @import_rate = import_rate
        @normalised_linear_export_rate = normalised_linear_export_rate
        @normalised_linear_import_rate = normalised_linear_import_rate
        @estimated_usage = estimated_usage
        @projected_remaining_battery_power = projected_remaining_battery_power
        @running_cost = running_cost
        @solar_kwh = solar_kwh
        @soc_start_kwh = soc_start_kwh
        @soc_end_kwh = soc_end_kwh
        @p_batt_kw = p_batt_kw
        @grid_import_kwh = grid_import_kwh
        @grid_export_kwh = grid_export_kwh
        @profit = profit
      end
    end
  end
end
