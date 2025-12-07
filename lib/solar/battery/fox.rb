require "faraday"
require "date"

module Solar
  module Battery
    class Fox
      autoload :Middleware, "solar/battery/fox/middleware"
      autoload :Request, "solar/battery/fox/request"

      def initialize(api_key:, serial_number:)
        @api_key = api_key
        @base_url = "https://www.foxesscloud.com"
        @client = Faraday.new(url: @base_url) do |f|
          f.request :json
          f.response :json
          f.use Solar::Battery::Fox::Middleware, api_key: @api_key
        end
        @serial_number = serial_number
      end

      def battery_charge
        history
          .filter { |data| data.dig("variable") == "SoC" }
          .dig(0, "data")
          .map do |data|
            BatteryCharge.new(
              at: Time.parse(data.dig("time")),
              percentage: data.dig("value")
            )
          end
      end

      def solar_generated_power
        history
          .filter { |data| data.dig("variable") == "pvPower" }
          .dig(0, "data")
          .map do |data|
            GeneratedPower.new(
              at: Time.parse(data.dig("time")),
              watts: (data.dig("value") * 1000).round
            )
          end
      end

      def battery_discharge_power
        history
          .filter { |data| data.dig("variable") == "batDischargePower" }
          .dig(0, "data")
          .map do |data|
            DischargePower.new(
              at: Time.parse(data.dig("time")),
              watts: (data.dig("value") * 1000).round
            )
          end
      end
      
      def battery_charge_power
        history
          .filter { |data| data.dig("variable") == "batChargePower" }
          .dig(0, "data")
          .map do |data|
            ChargePower.new(
              at: Time.parse(data.dig("time")),
              watts: (data.dig("value") * 1000).round
            )
          end
      end

      def grid_discharge_power
        history
          .filter { |data| data.dig("variable") == "feedinPower" }
          .dig(0, "data")
          .map do |data|
            GridDischargePower.new(
              at: Time.parse(data.dig("time")),
              watts: (data.dig("value") * 1000).round
            )
          end
      end

      def grid_charge_power
        history
          .filter { |data| data.dig("variable") == "gridConsumptionPower" }
          .dig(0, "data")
          .map do |data|
            GridChargePower.new(
              at: Time.parse(data.dig("time")),
              watts: (data.dig("value") * 1000).round
            )
          end
      end

      def load_power
        history
          .filter { |data| data.dig("variable") == "loadsPower" }
          .dig(0, "data")
          .map do |data|
            LoadPower.new(
              at: Time.parse(data.dig("time")),
              watts: (data.dig("value") * 1000).round
            )
          end
      end

      def history
        @history ||= @client.post(
          "/op/v0/device/history/query",
          {
            sn: @serial_number
          }
        ).then do |response|
          response.body.dig("result", 0, "datas")
        end
      end

      def work_mode
        @client.post(
          '/op/v0/device/setting/get',
          {
            sn: @serial_number,
            key: "WorkMode"
          }
        ).then do |response|
          response.body.dig("result", "value")
        end
      end

      def clear_schedule!
        today = Date.today
        from = DateTime.new(today.year, today.month, today.day, 0, 0, 0)
        to = DateTime.new(today.year, today.month, today.day, 23, 59, 0)
        schedule_group = Request::ScheduleGroup.self_use(from: from, to: to)

        request = Request::DeviceSchedulerEnable.new(
          serial_number: @serial_number,
          schedule_groups: [schedule_group.to_h]
        )

        @client.post(
          '/op/v1/device/scheduler/enable',
          request.to_h
        )
      end

      def force_discharge!
        today = Date.today
        from = DateTime.new(today.year, today.month, today.day, 0, 0, 0)
        to = DateTime.new(today.year, today.month, today.day, 23, 59, 0)
        schedule_group = Request::ScheduleGroup.force_discharge(from: from, to: to)

        request = Request::DeviceSchedulerEnable.new(
          serial_number: @serial_number,
          schedule_groups: [schedule_group.to_h]
        )

        @client.post(
          '/op/v1/device/scheduler/enable',
          request.to_h
        )
      end

      def force_charge!
        today = Date.today
        from = DateTime.new(today.year, today.month, today.day, 0, 0, 0)
        to = DateTime.new(today.year, today.month, today.day, 23, 59, 0)
        schedule_group = Request::ScheduleGroup.force_charge(from: from, to: to)

        request = Request::DeviceSchedulerEnable.new(
          serial_number: @serial_number,
          schedule_groups: [schedule_group.to_h]
        )

        @client.post(
          '/op/v1/device/scheduler/enable',
          request.to_h
        )
      end

      def set_scheduler!(schedule_groups: [])
        request = Request::DeviceSchedulerEnable.new(
          serial_number: @serial_number,
          schedule_groups: schedule_groups.map(&:to_h)
        )

        @client.post(
          '/op/v1/device/scheduler/enable',
          request.to_h
        ).then do |response|
          response.body
        end
      end
    end
  end
end