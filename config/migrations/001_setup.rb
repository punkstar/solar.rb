Sequel.migration do
  up do
    run "CREATE EXTENSION IF NOT EXISTS timescaledb"
    
    create_table(:consumption) do
      String :provider, null: false
      Integer :watt_hours, null: false
      Timestamptz :from, null: false
      Timestamptz :to, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:from, :provider]
    end

    create_table(:forecast_solar) do
      String :provider, null: false
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at, :provider]
    end

    create_table(:forecast_weather) do
      String :provider, null: false
      Timestamptz :at, null: false
      Float :temperature, null: false
      Float :snowfall, null: false
      Float :showers, null: false
      Float :rain, null: false
      Float :cloud_cover_2m, null: false
      Float :cloud_cover_high, null: false
      Float :cloud_cover_mid, null: false
      Float :cloud_cover_low, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at, :provider]
    end

    create_table(:rates) do
      String :provider, null: false
      String :direction, null: false
      String :tariff, null: false
      Float :rate, null: false
      Timestamptz :from, null: false
      Timestamptz :to, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:from, :provider, :direction, :tariff]
    end
  end

  down do
    drop_table(:consumption)
    drop_table(:forecast_solar)
    drop_table(:forecast_weather)
    drop_table(:rates)
  end
end
