class ProceduresController < ApplicationController
  def index
    if current_user.admin?
      @procedures = Procedure.all
      @priviledged = true
    elsif current_user.trainer?
      #TODO: Limit this to all procedures within the residency location for this user.
      @procedures = Procedure.all
      @priviledged = true
    else
      @procedures = Procedure.where user_id: current_user.id
      @priviledged = false
    end

    @users = User.all
  end

  def create
  	create_params = procedure_params

    if current_user.admin?
      params[:procedure][:confirmation] = true
      params[:procedure][:trainer_id] = current_user.id
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:residentstatus] = trainee.status
    elsif current_user.trainer?
      params[:procedure][:confirmation] = true
      params[:procedure][:trainer_id] = current_user.id
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:residentstatus] = trainee.status
    else
      params[:procedure][:confirmation] = false
      params[:procedure][:residentstatus] = current_user.status
      params[:procedure][:resident_name] = current_user.name
      params[:procedure][:user_id] = current_user.id
      params[:procedure][:trainer_id] = -1
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
  	params.require(:procedure).permit(:resident_name, :name, :date, :assistance, :confirmation, :notes, :gestation, :residentstatus, :user_id, :trainer_id, :clinic_location)
  end
end