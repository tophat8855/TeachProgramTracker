class ProceduresController < ApplicationController
  def index
  	@procedures = Procedure.all
  end

  def create
  	create_params = procedure_params

    if current_user.admin?
      params[:procedure][:confirmation] = true
    elsif current_user.trainer?
      params[:procedure][:confirmation] = true
    else
      params[:procedure][:confirmation] = false
      params[:procedure][:residentstatus] = current_user.status
      params[:procedure][:resident] = current_user.name
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

  	@users = User.all
  	@procedure = Procedure.new
  end

  def procedure_params
  	params.require(:procedure).permit(:resident, :name, :date, :assistance, :confirmation, :notes, :gestation, :residentstatus)
  end
end