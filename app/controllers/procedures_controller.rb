class ProceduresController < ApplicationController
  def index
  	@procedures = Procedure.all
  end

  def create
  	#This is broken and should be moved into the new method.  Don't know how to populate parameters before-hand yet.
    if current_user.admin?
      params[:confirmation] = true 
    elsif current_user.trainer?
      params[:confirmation] = true
    else
      params[:confirmation] = false
    end

    #Resident status should be modified here once that is implemented.  R1, R2, R3, R4 

  	Procedure.create(procedure_params)
  	redirect_to procedures_path
  end

  def new
  	if current_user.admin?
      @allowNameEntry = true
      @residentName = ""
    elsif current_user.trainer?
      @allowNameEntry = true
      @residentName = ""
    else
      @allowNameEntry = false
      @residentName = current_user.name
    end

  	@procedure = Procedure.new
  end

  def procedure_params
  	params.require(:procedure).permit(:resident, :name, :date, :assistance, :confirmation, :notes, :gestation, :residentstatus)
  end
end