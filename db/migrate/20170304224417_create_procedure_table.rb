class CreateProcedureTable < ActiveRecord::Migration[5.0]
  def change
    create_table :procedures do |t|
    	t.string :resident
    	t.date :date
    	t.string :name
    	t.string :assistance
    	t.boolean :confirmation
    	t.text :notes
    	t.float :gestation
    	t.string :residentstatus

    	t.timestamps
    end
  end
end
