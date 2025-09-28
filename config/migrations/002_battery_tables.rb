Sequel.migration do
  up do
    create_table(:battery_charge) do
      Timestamptz :at, null: false
      Integer :percentage, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end

    create_table(:solar_generated_power) do
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end

    create_table(:battery_discharge_power) do
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end
    
    create_table(:battery_charge_power) do
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end

    create_table(:grid_discharge_power) do
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end

    create_table(:grid_charge_power) do
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end

    create_table(:load_power) do
      Timestamptz :at, null: false
      Integer :watts, null: false
      Timestamp :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      Timestamp :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      primary_key [:at]
    end
  end

  down do
    drop_table(:battery_charge)
    drop_table(:solar_generated_power)
    drop_table(:battery_discharge_power)
    drop_table(:battery_charge_power)
    drop_table(:grid_discharge_power)
    drop_table(:grid_charge_power)
    drop_table(:load_power)
  end
end
