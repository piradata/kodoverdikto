# require "devise_token_auth"
require "sidekiq/web"

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  Sidekiq::Web.use(Rack::Protection, { use: :authenticity_token, logging: true, message: "Didn't work!" })

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :users do
    member do
      post :impersonate
    end
    collection do
      post :stop_impersonating
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "application#homepage"
end
