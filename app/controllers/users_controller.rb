class UsersController < ApplicationController
  def index
    if current_user.admin?
      @users = User.where(admin: false).order("trainer DESC")
    elsif current_user.trainer?
      @users = User.where(admin: false, trainer: false, residency_location_id: current_user.residency_location_id)
    else
      redirect_to user_path(current_user)
    end
  end

  def show
    @user = User.find_by(id: params[:id])

    #@resdency_location = ResidencyLocation.find_by(id: params[:residency_location_id])

    # Uncomment after Procedure Table is created
    # @procedures = Procedure.all.where(user_id = @user.id)

    unless current_user_has_access_to_user(@user)
      redirect_to root_path
    end
  end

  def new
    @user = User.new
  end

  def create
    user = User.new(user_params)
    if user.save
      redirect_to users_path
    else
      render :new
    end
  end

  def edit
    @user = User.find_by(id: params[:id])
    unless current_user_has_access_to_user(@user)
      redirect_to root_path
    end
  end

  def update
    @user = User.find_by(id: params[:id])

    if @user.update_attributes(user_params)
      redirect_to users_path
    else redirect_to
      redirect_to edit_user_path(@user)
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    if current_user_has_access_to_user(user)
      user.destroy
      redirect_to users_path
    else
      redirect_to root_path
    end
  end

  def invite
    User.invite!(email: params[:email])
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :residency_location_id, :status, :trainer,
    :admin)
  end

  def current_user_has_access_to_user(user)
    if current_user != user
      if user.admin?
        return false
      elsif user.trainer? && !current_user.trainer? && !current_user.admin?
        return false
      elsif !current_user.trainer? && !current_user.admin?
        return false
      end
    end
    return true
  end
end
