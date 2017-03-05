class ProceduresController < ApplicationController
  def index
  	@procedures = Procedure.all
  end

  def create
  	Procedure.create(procedure_params)
  	redirect_to procedures_path
  end

  def new
  	@procedure = Procedure.new
  end

  def procedure_params
  	params.require(:procedure).permit(:resident, :name, :date, :assistance, :confirmation, :notes, :gestation, :residentstatus)
  end
end