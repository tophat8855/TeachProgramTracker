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
      @procedures = Procedure.where(user_id: current_user.id).order(date: :desc)
      @priviledged = false
    end

  	# @filterrific = initialize_filterrific(
  	# 	Procedure,
  	# 	params[:filterrific],
    #   select_options: {
    #     by_user_id: current_user.id
    #   },
    #   available_filters: [:by_user_id]
  	# ) or return
  	# @procedures = @filterrific.find.page(params[:page])

  	respond_to do |format|
  		format.html
  		format.js {render inline: "location.reload();" }
  	end
  end

  def show
    @procedure = Procedure.find_by(id: params[:id])
    @trainer_name = @procedure.trainer_name
  end

  def new
    if current_user.admin? || current_user.trainer?
      @allowNameEntry = true
      @residentName = ""
    else
      @allowNameEntry = false
      @residentName = current_user.name
    end

    if flash[:procid].nil?
      @procedure = Procedure.new
    else
      old_id = flash[:procid].inspect
      last_procedure = Procedure.find_by(id: old_id)
      @procedure = Procedure.new(last_procedure.attributes.merge({:id => nil}))
    end

    @users = User.all
    @trainers = (User.where(trainer: true).pluck(:name) + Procedure.all.pluck(:trainer_name)).uniq.select(&:present?)
    @clinic_locations = (Procedure::CLINIC_LOCATIONS + Procedure.all.pluck(:clinic_location)).uniq
  end

  def create
    unless params['New Clinic Location'].empty?
      params[:procedure][:clinic_location] = params['New Clinic Location']
    end

    unless params['New Trainer'].empty?
      params[:procedure][:trainer_name] = params['New Trainer']
    else
      trainer = User.find_by(name: params[:procedure][:trainer_name])
    end

    if current_user.admin? || current_user.trainer?
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:resident_status] = trainee.status
    else
      params[:procedure][:resident_status] = current_user.status
      params[:procedure][:resident_name] = current_user.name
      params[:procedure][:user_id] = current_user.id
    end

    pp = Procedure.create(procedure_params)
    if params[:addanother] == 'Submit and Add Another'
      redirect_to new_procedure_path, flash: {procid: pp.id}
      #redirect_to controller: 'procedure', action: 'new' , procid: proc.id
    else
      redirect_to procedures_path
    end
  end

  def edit
    if current_user.admin? || current_user.trainer?
      @allowNameEntry = true
      @residentName = ""
    else
      @allowNameEntry = false
      @residentName = current_user.name
    end

  	@users = User.all.reverse
  	@procedure = Procedure.find_by(id: params[:id])
    @trainers = (User.where(trainer: true).pluck(:name) + Procedure.all.pluck(:trainer_name)).uniq.select(&:present?)
    @clinic_locations = (Procedure::CLINIC_LOCATIONS + Procedure.all.pluck(:clinic_location)).uniq
  end

  def update
  	@procedure = Procedure.find_by(id: params[:id])

    unless params['New Clinic Location'].empty?
      params[:procedure][:clinic_location] = params['New Clinic Location']
    end

    if !params['New Trainer'].empty?
      params[:procedure][:trainer_name] = params['New Trainer']
    elsif custom_trainer?
      params[:procedure][:trainer_name] = params[:procedure][:trainer_name]
    else
      trainer = User.find_by(name: params[:procedure][:trainer_name])
    end

    if current_user.admin? || current_user.trainer?
      trainee = User.find(params[:procedure][:user_id])
      params[:procedure][:resident_name] = trainee.name
      params[:procedure][:resident_status] = trainee.status
    else
      params[:procedure][:resident_status] = current_user.status
      params[:procedure][:resident_name] = current_user.name
      params[:procedure][:user_id] = current_user.id
    end

    if @procedure.update_attributes(procedure_params)
      redirect_to procedures_path
    else
      redirect_to edit_procedure_path(@procedure)
    end
  end

  def destroy
    procedure = Procedure.find_by(id: params[:id])
    procedure.destroy
    redirect_to procedures_path
  end

  def procedure_params
  	params.require(:procedure).permit(:resident_name, :name, :date, :assistance, :notes, :gestation, :resident_status, :user_id, :trainer_name, :clinic_location)
  end

  private
  def custom_trainer?
    User.find_by(name: params[:procedure][:trainer_name]).nil?
  end
end
