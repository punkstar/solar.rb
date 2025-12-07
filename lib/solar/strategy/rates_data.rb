module Solar
  module Strategy
    class RatesData
      AGILE_IMPORT_TARIFF = "E-1R-AGILE-24-10-01-L"
      AGILE_EXPORT_TARIFF = "E-1R-AGILE-OUTGOING-19-05-13-L"
      FLUX_EXPORT_TARIFF = "E-1R-FLUX-EXPORT-23-02-14-L"
      FLUX_IMPORT_TARIFF = "E-1R-FLUX-IMPORT-23-02-14-L"

      def initialize(database:)
        @database = database
      end

      # Query agile import rate for a specific time
      # @param time [Time] Time that must lie between from and to in the schema
      # @return [Hash, nil] Rate record with :from, :to, :rate keys, or nil if not found
      def agile_import_rates(time:)
        record = @database[:rates]
          .where(
            tariff: AGILE_IMPORT_TARIFF,
            direction: "import",
            provider: "octopus"
          )
          .where(Sequel.lit("\"from\" <= ? AND ? < \"to\"", time, time))
          .first

        record ? { from: record[:from], to: record[:to], rate: record[:rate] } : nil
      end

      # Query agile export rate for a specific time
      # @param time [Time] Time that must lie between from and to in the schema
      # @return [Hash, nil] Rate record with :from, :to, :rate keys, or nil if not found
      def agile_export_rates(time:)
        record = @database[:rates]
          .where(
            tariff: AGILE_EXPORT_TARIFF,
            direction: "export",
            provider: "octopus"
          )
          .where(Sequel.lit("\"from\" <= ? AND ? < \"to\"", time, time))
          .first

        record ? { from: record[:from], to: record[:to], rate: record[:rate] } : nil
      end

      # Query flux export rate for a specific time
      # @param time [Time] Time that must lie between from and to in the schema
      # @return [Hash, nil] Rate record with :from, :to, :rate keys, or nil if not found
      def flux_export_rates(time:)
        record = @database[:rates]
          .where(
            tariff: FLUX_EXPORT_TARIFF,
            direction: "export",
            provider: "octopus"
          )
          .where(Sequel.lit("\"from\" <= ? AND ? < \"to\"", time, time))
          .first

        record ? { from: record[:from], to: record[:to], rate: record[:rate] } : nil
      end

      # Query flux import rate for a specific time
      # @param time [Time] Time that must lie between from and to in the schema
      # @return [Hash, nil] Rate record with :from, :to, :rate keys, or nil if not found
      def flux_import_rates(time:)
        record = @database[:rates]
          .where(
            tariff: FLUX_IMPORT_TARIFF,
            direction: "import",
            provider: "octopus"
          )
          .where(Sequel.lit("\"from\" <= ? AND ? < \"to\"", time, time))
          .first

        record ? { from: record[:from], to: record[:to], rate: record[:rate] } : nil
      end 
    end
  end
end
