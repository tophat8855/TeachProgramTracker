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

	@filterrific = initialize_filterrific(
		Procedure,
		params[:filterrific]
	) or return
	@procedures = @filterrific.find.page(params[:page])

	respond_to do |format|
		format.html
		format.js
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

  def destroy
    procedure = Procedure.find_by(id: params[:id])
    procedure.destroy
    redirect_to procedures_path
  end

  def update
  	#TODO: Update the parameters that are intercepted in create in update if needed.
  	@procedure = Procedure.find_by(id: params[:id])
    
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

    if @procedure.update_attributes(procedure_params)
      redirect_to procedures_path
    else
      redirect_to edit_procedure_path(@procedure)
    end
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

  def show
    @procedure = Procedure.find_by(id: params[:id])
  end

  def procedure_params
  	params.require(:procedure).permit(:resident_name, :name, :date, :assistance, :confirmation, :notes, :gestation, :residentstatus, :user_id, :trainer_id, :clinic_location)
  end
end