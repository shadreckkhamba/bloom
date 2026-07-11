Rails.application.routes.draw do
  root "dashboard#index"

  # Auth
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy",  as: :logout
  get    "/signup", to: "registrations#new", as: :signup
  post   "/signup", to: "registrations#create"

  # Dashboard
  get "/dashboard", to: "dashboard#index",    as: :dashboard
  get "/messages",  to: "dashboard#messages", as: :messages

  # Wedding management
  resource :wedding, only: [:new, :create, :edit, :update, :show]

  # Partner accounts
  get    "/partner/invite",      to: "partners#invite",     as: :partner_invite
  post   "/partner/regenerate",  to: "partners#regenerate", as: :partner_regenerate
  get    "/partner/accept",      to: "partners#accept",     as: :partner_accept
  post   "/partner/accept",      to: "partners#confirm"
  delete "/partner",             to: "partners#destroy",    as: :partner_destroy

  # Guest management
  resources :guests, only: [:index, :create, :destroy] do
    collection do
      post :import
      post :send_invitations
    end
    member do
      patch :mark_sent
    end
  end

  # Check-in
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
