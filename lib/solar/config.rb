require "singleton"
require "yaml"
require "sequel"

module Solar
  class Config
    include Singleton

    PanelGroup = Data.define(:azimuth, :declination, :watts) do
      def kilowatts
        watts / 1000.0
      end
    end

    def database
      @database ||= Sequel.connect(data.dig("database", "connection"))
    end

    def meter_provider
      data.dig("installation", "meter", "provider")
    end

    def meter_api_key
      data.dig("installation", "meter", "api_key")
    end

    def meter_mpan
      data.dig("installation", "meter", "mpan")
    end

    def meter_serial
      data.dig("installation", "meter", "serial")
    end

    def meter_import_product
      data.dig("installation", "meter", "import_product")
    end

    def meter_import_tariff
      data.dig("installation", "meter", "import_tariff")
    end

    def meter_export_product
      data.dig("installation", "meter", "export_product")
    end

    def meter_export_tariff
      data.dig("installation", "meter", "export_tariff")
    end

    def installation_lat
      data.dig("installation", "lat")
    end

    def installation_lon
      data.dig("installation", "lon")
    end
    
    def forecast_api_key
      data.dig("forecast", "api_key")
    end

    def battery_api_key
      data.dig("installation", "battery", "api_key")
    end

    def battery_provider
      data.dig("installation", "battery", "provider")
    end

    def battery_serial
      data.dig("installation", "battery", "serial")
    end

    def inverter_provider
      data.dig("installation", "inverter", "provider")
    end

    def inverter_serial
      data.dig("installation", "inverter", "serial")
    end

    def panel_groups
      data.dig("installation", "groups").map do |group|
        PanelGroup.new(
          azimuth: group.dig("azimuth"),
          declination: group.dig("declination"),
          watts: group.dig("panel_watts") * group.dig("panels")
        )
      end
    end

    private

    def data
      @data ||= YAML.load_file("plant.yml")
    end
  end
end