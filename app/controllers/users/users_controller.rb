class Users::UsersController < ApplicationController
  # your authorization method
  before_action :require_admin!, only: [:impersonate, :stop_impersonating]

  def index
    @users = User.order(:id)
  end

  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

end
