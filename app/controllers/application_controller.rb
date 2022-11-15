class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  impersonates :user

  def homepage
  end

  def access_denied
    render_403
  end

  def require_admin!
    raise "unauthorized!" unless true_user.admin?
  end

  def render_403(_arg = nil)
    render "error/error_card", formats: [:html], status: :forbidden, locals: { error_code: 403, icon: "🔒"}
  end

  def render_404(_arg = nil)
    render "error/error_card", formats: [:html], status: :not_found, locals: { error_code: 404, icon: "🔎"}
  end

  def render_500(_arg = nil)
    render "error/error_card", formats: [:html], status: :internal_server_error, locals: { error_code: 500, icon: ":("}
  end

end
