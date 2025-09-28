module Solar
  class Repository
    def initialize(database:)
      @database = database
    end

    def save(records, table:)
      records.each do |record|
        save_record(record, table:)
      end
    end

    private

    def save_record(record, table:)
      case record
      when Solar::Provider::Consumption
        @database[:consumption].insert_conflict(
          target: [:from, :provider],
          update: {
            watt_hours: Sequel[:excluded][:watt_hours],
            to: Sequel[:excluded][:to]
          }
        ).insert(
          watt_hours: record.watt_hours,
          from: record.from,
          to: record.to,
          provider: record.provider
        )
        when Solar::Forecast::PowerForecast
          @database[:forecast_solar].insert_conflict(
            target: [:at, :provider],
            update: { watts: Sequel[:excluded][:watts] }
          ).insert(
            watts: record.watts,
            at: record.at,
            provider: record.provider
          )
        when Solar::Forecast::WeatherForecast
          @database[:forecast_weather].insert_conflict(
            target: [:at, :provider],
            update: {
              temperature: Sequel[:excluded][:temperature],
              snowfall: Sequel[:excluded][:snowfall],
              showers: Sequel[:excluded][:showers],
              rain: Sequel[:excluded][:rain],
              cloud_cover_2m: Sequel[:excluded][:cloud_cover_2m],
              cloud_cover_high: Sequel[:excluded][:cloud_cover_high],
              cloud_cover_mid: Sequel[:excluded][:cloud_cover_mid],
              cloud_cover_low: Sequel[:excluded][:cloud_cover_low]
            }
          ).insert(
            temperature: record.temperature,
            snowfall: record.snowfall,
            showers: record.showers,
            rain: record.rain,
            cloud_cover_2m: record.cloud_cover_2m,
            cloud_cover_high: record.cloud_cover_high,
            cloud_cover_mid: record.cloud_cover_mid,
            cloud_cover_low: record.cloud_cover_low,
            at: record.at,
            provider: record.provider
          )
        when Solar::Provider::Rate
          @database[:rates].insert_conflict(
            target: [:from, :provider, :direction, :tariff],
            update: { rate: Sequel[:excluded][:rate] }
          ).insert(
            rate: record.rate,
            from: record.from,
            to: record.to,
            provider: record.provider,
            direction: record.direction,
            tariff: record.tariff
          )
      else
        raise "Unknown record type: #{record.class}"
      end
    end
  end
end