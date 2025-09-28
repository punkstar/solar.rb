module Solar
  module Provider
    autoload :Octopus, "solar/provider/octopus"

    Consumption = Data.define(:watt_hours, :from, :to, :provider)
    Rate = Data.define(:rate, :from, :to, :provider, :direction, :tariff)
  end
end