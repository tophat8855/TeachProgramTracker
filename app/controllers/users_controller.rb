class UsersController < ApplicationController
  def index
    if current_user.admin?
      @users = User.where(admin: false).order("trainer DESC")
    elsif current_user.trainer?
      @users = User.where(admin: false, trainer: false)
    else
      redirect_to user_path(current_user)
    end
  end

  def show
    @user = User.find_by(id: params[:id])
    unless current_user_has_access_to_user(@user)
      redirect_to root_path
    end
  end

  def edit
    @user = User.find_by(id: params[:id])
    unless current_user_has_access_to_user(@user)
      redirect_to root_path
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

  private

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
