class ProcedureUsesTrainerNameInsteadOfId < ActiveRecord::Migration[5.0]
  def change
    add_column :procedures, :trainer_name, :string
  end
end
