module Solar
  module Battery
    class Fox
      autoload :Middleware, "solar/battery/fox/middleware"

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
        # @client.post(
        #   "/op/v2/device/scheduler/enable",
        #   {
        #     deviceSN: @serial_number,
        #     groups: [{
        #       enable: 0,
        #       startHour: 0,
        #       startMinute: 0,
        #       endHour: 23,
        #       endMinute: 59,
        #       workMode: 'SelfUse',
        #       extraParam: {
        #         minSocOnGrid: 10,
        #         fdSoc: 10,
        #         fdPwr: 1000,
        #         maxSoc: 100
        #       }
        #     }]
        #   }
        # )
        @client.post(
          '/op/v0/device/scheduler/enable',
          {
            deviceSN: @serial_number,
            groups: [
              {
                enable: 1,
                startHour: 0,
                startMinute: 0,
                endHour: 23,
                endMinute: 59,
                workMode: "SelfUse",
                minSocOnGrid: 10,
                fdSoc: 100,
                fdPwr: 3000
              }
            ]
          }
        )
      end

      def force_discharge!
        @client.post(
          '/op/v0/device/scheduler/enable',
          {
            deviceSN: @serial_number,
            groups: [
              {
                enable: 1,
                startHour: 0,
                startMinute: 0,
                endHour: 23,
                endMinute: 59,
                workMode: "ForceDischarge",
                minSocOnGrid: 10,
                fdSoc: 10,
                fdPwr: 3000
              }
            ]
          }
        )
      end

      def force_charge!
        @client.post(
          '/op/v0/device/scheduler/enable',
          {
            deviceSN: @serial_number,
            groups: [
              {
                enable: 1,
                startHour: 0,
                startMinute: 0,
                endHour: 23,
                endMinute: 59,
                workMode: "ForceCharge",
                minSocOnGrid: 10,
                maxSoc: 100,
                fdSoc: 100,
                fdPwr: 3000
              }
            ]
          }
        )
      end
    end
  end
end