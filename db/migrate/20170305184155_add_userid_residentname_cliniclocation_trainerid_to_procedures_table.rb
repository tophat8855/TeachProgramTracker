class AddUseridResidentnameCliniclocationTraineridToProceduresTable < ActiveRecord::Migration[5.0]
  def change
    rename_column :procedures, :resident, :resident_name

    add_column :procedures, :user_id, :integer
    add_column :procedures, :trainer_id, :integer
    add_column :procedures, :clinic_location, :string
  end
end
