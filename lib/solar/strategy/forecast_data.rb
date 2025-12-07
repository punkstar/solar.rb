module Solar
  module Strategy
    class ForecastData
      def initialize(database:)
        @database = database
      end

      # Query solar forecast for a time range
      # @param from [Time] Start time
      # @param to [Time] End time
      # @return [Array<Hash>] Array of forecast records with :at, :watts keys
      def solar_forecast(from:, to:)
        @database[:forecast_solar]
          .where { (at >= from) & (at < to) }
          .order(:at)
          .map { |r| { at: r[:at], watts: r[:watts] } }
      end

      # Get solar forecast for a specific time
      # @param time [Time] The time to query
      # @return [Integer, nil] Forecasted watts or nil if not found
      def forecast_at(time:)
        record = @database[:forecast_solar]
          .where { at <= time }
          .order(Sequel.desc(:at))
          .limit(1)
          .first

        record&.dig(:watts)
      end
    end
  end
end
