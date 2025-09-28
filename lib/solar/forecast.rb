module Solar
  module Forecast
    autoload :SolarForecast, "solar/forecast/solar_forecast"
    autoload :OpenMeteo, "solar/forecast/open_meteo"

    PowerForecast = Data.define(:at, :watts, :provider)
    WeatherForecast = Data.define(
      :at, :temperature, :provider,
      :snowfall, :showers, :rain,
      :cloud_cover_2m, :cloud_cover_high, :cloud_cover_mid, :cloud_cover_low
    )
  end
end