class AccountsController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(account_params)
      redirect_to dashboard_path, notice: "Account updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    attrs = params.require(:user).permit(:name, :username, :password, :password_confirmation)
    attrs[:name] = attrs[:name].to_s.strip if attrs.key?(:name)
    attrs[:username] = attrs[:username].to_s.downcase.strip if attrs.key?(:username)

    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end

    attrs
  end
end
