module Solar
  module Forecast
    class OpenMeteo
      def initialize
        @client = Faraday.new(url: "https://api.open-meteo.com") do |f|
          f.request :json
          f.response :json
        end
      end

      def forecast(lat:, lon:)
        url = "/v1/forecast?latitude=#{lat}&longitude=#{lon}&hourly=temperature_2m,snowfall,showers,rain,cloud_cover_2m,cloud_cover_high,cloud_cover_mid,cloud_cover_low&models=ukmo_seamless"
        result = @client.get(url)
        hourly_data = result.body.dig("hourly")

        internal_forecast = hourly_data["time"].map do |time|
          {
            at: Time.parse(time + " UTC"),
          }
        end

        hourly_data.each do |label, items|
          next if label == "time"

          items.each_with_index do |item, index|
            internal_forecast[index][label.to_sym] = item
          end
        end

        internal_forecast.map do |forecast|
          WeatherForecast.new(
            provider: "open_meteo",
            at: forecast[:at],
            temperature: forecast[:temperature_2m],
            snowfall: forecast[:snowfall],
            showers: forecast[:showers],
            rain: forecast[:rain],
            cloud_cover_2m: forecast[:cloud_cover_2m],
            cloud_cover_high: forecast[:cloud_cover_high],
            cloud_cover_mid: forecast[:cloud_cover_mid],
            cloud_cover_low: forecast[:cloud_cover_low]
          )
        end
      end
    end
  end
end