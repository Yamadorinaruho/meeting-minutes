Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resource :profile, only: [:show, :new, :create, :edit, :update]
  resources :meetings, only: [:index, :show, :new, :create, :destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
