class SettingsController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(settings_params)
      redirect_to settings_path, notice: "Settings saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy_avatar
    Current.user.avatar.purge if Current.user.avatar.attached?
    redirect_to settings_path, notice: "Avatar removed.", status: :see_other
  end

  private

  def settings_params
    params.require(:user).permit(:name, :timezone, :week_start, :avatar)
  end
end
