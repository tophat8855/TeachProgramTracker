class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :name

      t.timestamps
    end

    add_column :users, :location_id, :integer
  end
end
