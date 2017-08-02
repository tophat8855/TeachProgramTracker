class RemoveTrainerIdFromProcedures < ActiveRecord::Migration[5.0]
  def change
    remove_column :procedures, :trainer_id
  end
end
