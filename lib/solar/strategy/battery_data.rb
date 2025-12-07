module Solar
  module Strategy
    class BatteryData
      def initialize(database:)
        @database = database
      end

      # Returns the most recent battery charge percentage
      # @return [Integer, nil] Battery charge percentage (0-100) or nil if no data
      def current_charge
        record = @database[:battery_charge]
          .order(Sequel.desc(:at))
          .limit(1)
          .first

        record&.dig(:percentage)
      end

      # Returns battery charge at a specific time
      # @param time [Time] The time to query
      # @return [Integer, nil] Battery charge percentage or nil if not found
      def charge_at(time:)
        record = @database[:battery_charge]
          .where { at <= time }
          .order(Sequel.desc(:at))
          .limit(1)
          .first

        record&.dig(:percentage)
      end
    end
  end
end
