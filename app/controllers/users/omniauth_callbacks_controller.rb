# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)

    if @user.present?
      sign_out_all_scopes
      flash[:success] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:alert] = I18n.t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} not authorized"
      redirect_to new_user_session_path
    end
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
