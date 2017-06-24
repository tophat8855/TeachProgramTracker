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
    @trainers = User.all.where(trainer: true)
    @clinic_locations = (Procedure::CLINIC_LOCATIONS + Procedure.all.pluck(:clinic_location)).uniq
  end

  def create
  	create_params = procedure_params

    if params['New Clinic Location']
      params[:procedure][:clinic_location] = params['New Clinic Location']
    end

    if current_user.admin?
      params[:procedure][:trainer_id] = current_user.id
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:residentstatus] = trainee.status
    elsif current_user.trainer?
      params[:procedure][:trainer_id] = current_user.id
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:residentstatus] = trainee.status
    else
      params[:procedure][:residentstatus] = current_user.status
      params[:procedure][:resident_name] = current_user.name
      params[:procedure][:user_id] = current_user.id
    end

  	Procedure.create(procedure_params)
  	redirect_to procedures_path
  end

  def edit
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
  	@procedure = Procedure.find_by(id: params[:id])
    @trainers = User.all.where(trainer: true)
    @clinic_locations = (Procedure::CLINIC_LOCATIONS + Procedure.all.pluck(:clinic_location)).uniq
  end

  def update
  	@procedure = Procedure.find_by(id: params[:id])

    if params['New Clinic Location']
      params[:procedure][:clinic_location] = params['New Clinic Location']
    end

    if current_user.admin?
      params[:procedure][:trainer_id] = current_user.id
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:residentstatus] = trainee.status
    elsif current_user.trainer?
      params[:procedure][:trainer_id] = current_user.id
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:residentstatus] = trainee.status
    else
      params[:procedure][:residentstatus] = current_user.status
      params[:procedure][:resident_name] = current_user.name
      params[:procedure][:user_id] = current_user.id
    end

    if @procedure.update_attributes(procedure_params)
      redirect_to procedures_path
    else
      redirect_to edit_procedure_path(@procedure)
    end
  end

  def show
    @procedure = Procedure.find_by(id: params[:id])
    @trainer_name = @procedure.trainer_id != -1 ? User.find_by(id: @procedure.trainer_id).name : ''
  end

  def destroy
    procedure = Procedure.find_by(id: params[:id])
    procedure.destroy
    redirect_to procedures_path
  end

  def procedure_params
  	params.require(:procedure).permit(:resident_name, :name, :date, :assistance, :notes, :gestation, :residentstatus, :user_id, :trainer_id, :clinic_location)
  end
end
