Rails.application.routes.draw do
  root "dashboard#index"

  # Auth
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy",  as: :logout
  get    "/signup", to: "registrations#new", as: :signup
  post   "/signup", to: "registrations#create"

  # Florence's dashboard
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # Wedding management
  resource :wedding, only: [:new, :create, :edit, :update, :show]

  # Guest management (nested under wedding)
  resources :guests, only: [:index, :create, :destroy] do
    collection do
      post :import
      post :send_invitations
    end
    member do
      patch :mark_sent
    end
  end

  # Check-in (venue volunteers)
  get  "/checkin",      to: "checkin#index",  as: :checkin
  post "/checkin/scan", to: "checkin#scan",   as: :checkin_scan

  # Guest-facing invitation (public)
  scope "/i" do
    get  "/:token",        to: "invitations#show",   as: :invitation
    post "/:token/verify", to: "invitations#verify", as: :invitation_verify
    post "/:token/rsvp",   to: "invitations#rsvp",   as: :invitation_rsvp
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
