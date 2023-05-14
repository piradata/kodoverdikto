class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:access_denied, :render403, :render404, :render500]
  impersonates :user

  def homepage
  end

  def access_denied(exception=nil)
    render403
  end

  def require_admin!
    raise "unauthorized!" unless true_user.admin?
  end

  def render403(_arg = nil)
    render "error/error_card", formats: [:html], status: :forbidden, locals: { error_code: 403, icon: "🔒"}
  end

  def render404(_arg = nil)
    render "error/error_card", formats: [:html], status: :not_found, locals: { error_code: 404, icon: "🔎"}
  end

  def render500(_arg = nil)
    render "error/error_card", formats: [:html], status: :internal_server_error, locals: { error_code: 500, icon: ":("}
  end

end
