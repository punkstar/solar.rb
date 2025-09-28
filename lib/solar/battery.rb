module Solar
  module Battery
    autoload :Fox, "solar/battery/fox"

    BatteryCharge = Data.define(:at, :percentage)
    GeneratedPower = Data.define(:at, :watts)
    DischargePower = Data.define(:at, :watts)
    ChargePower = Data.define(:at, :watts)
    GridDischargePower = Data.define(:at, :watts)
    GridChargePower = Data.define(:at, :watts)
    LoadPower = Data.define(:at, :watts)
  end
end