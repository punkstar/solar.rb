module Solar
  module Forecast
    class SolarForecast
      def initialize(api_key:)
        @api_key = api_key
        @client = Faraday.new(url: "https://api.forecast.solar") do |f|
          f.request :json
          f.response :json
        end
      end

      def forecast(panel_groups:, lat:, lon:)
        combined_watts = {}
        
        panel_groups.each do |panel_group|
          result = @client.get(
            "/#{@api_key}/estimate/#{lat}/#{lon}/#{panel_group.declination}/#{panel_group.azimuth}/#{panel_group.kilowatts}"
          )

          watts_data = result.body.dig("result", "watt_hours_period")
          
          watts_data.each do |time, watts|
            combined_watts[time] = (combined_watts[time] || 0) + watts
          end
        end
        
        combined_watts.map do |time, watts|
          PowerForecast.new(
            provider: "solar_forecast",
            at: Time.parse(time),
            watts: watts
          )
        end
      end
    end
  end
end