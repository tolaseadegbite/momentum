Rails.application.routes.draw do
  resource :session, only: %i[new create destroy]
  resources :passwords, only: %i[new create edit update], param: :token
  resource :registration, only: %i[new create]

  root "home#index"
  resource :dashboard, only: :show, controller: "dashboard"

  resources :habits do
    member do
      post :checkin
      delete :uncheck
      patch :archive
      patch :unarchive
    end
    resources :checkins, only: %i[index create destroy]
  end

  resources :mood_entries, only: %i[index create update destroy]
  get "stats" => "stats#show", as: :stats
  get "calendar" => "calendars#show", as: :calendar
  resource :settings, only: %i[show update], controller: "settings"

  get "up" => "rails/health#show", as: :rails_health_check

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
