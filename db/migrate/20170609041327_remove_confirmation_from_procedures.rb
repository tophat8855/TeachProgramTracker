class RemoveConfirmationFromProcedures < ActiveRecord::Migration[5.0]
  def change
    remove_column :procedures, :confirmation
  end
end
