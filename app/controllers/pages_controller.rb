class PagesController < ApplicationController
  def home
  end

  def profile
    @user = current_user
  end

  def edit_profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    if @user.update_with_password(profile_params)
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Profile updated successfully!"
    else
      render :edit_profile, status: :unprocessable_entity
    end
  end

  private
  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :current_password, :password_confirmation)
  end
end
