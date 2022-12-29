Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  root 'users#index'

  devise_for :users, controllers: {sessions: 'users/sessions', registrations: 'users/registrations',
             invitations: 'users/invitations', passwords: 'users/passwords' }, defaults: { format: :json }
  devise_scope :user do
    post '/register' => 'users/invitations#register', :as => :user_register, defaults: { format: :json }
    post 'teams/:id/invitation' => 'users/invitations#create', :as => :team_user_invitation, defaults: { format: :json }
    post '/teams' => 'users/invitations#team_invite', :as => :create_team, defaults: { format: :json }
    post '/accept_invite' => 'users/invitations#accept_invite', :as => :accept_user_invite, defaults: { format: :json }
    post 'teams/:team_id/add_members' => 'users/invitations#add_members', :as => :add_team_members, defaults: { format: :json }
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'users', to: 'users#index'
      get 'stats', to: 'teams#stats'
      get 'teams/:id', to: 'teams#team_info'
      get 'teams/:id/members', to: 'teams#team_members'
      # post 'reports', to: 'reports#create', :as => :create_report
      post '/upload', to: 'users#upload_picture'
      patch ':team_id/remove_member/:user_id', to: 'teams#remove_member'
      resources :teams, only: [:create, :index, :update]
      resources :reports, only: [:create] do
        collection do
          get '/:team_id', to: 'reports#index'
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "articles#index"
end
