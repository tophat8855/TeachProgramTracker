class RenameResidentstatusColumnToResidentStatus < ActiveRecord::Migration[5.0]
  def change
    rename_column :procedures, :residentstatus, :resident_status
  end
end
