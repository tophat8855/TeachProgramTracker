class ChangeLocationsToResidencyLocations < ActiveRecord::Migration[5.0]
  def change
    rename_table :locations, :residency_locations

    rename_column :users, :location_id, :residency_location_id
  end
end
