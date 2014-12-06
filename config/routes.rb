require 'sidekiq/web'

Yostalgia::Application.routes.draw do

  devise_for :private_public_searches, controllers: {
      passwords: 'private_public_search_passwords'
  }

  root to: 'static#app'

  devise_for :users, controllers: {
    sessions: 'sessions',
    confirmations: 'confirmations',
    passwords: 'passwords',
    omniauth_callbacks: 'omniauth_callbacks'
  }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :signups, only: :create do
        collection do
          get 'check_email'
          get 'check_username'
        end
      end
      resources :users, only: [:index, :show, :update]
      resources :friendships
      resources :profiles, only: [:show, :update]
      resources :profile_versions, only: :index
      resources :posts, only: [:index, :show, :create] do
        collection do
          get :search
        end
      end
      resources :attachments, only: [:index, :show, :create]
      resources :comments, only: [:index, :create, :destroy]
      resources :search_results, only: [:show, :index] do
        collection do
          get "password_validate"
          get "validate_with_user_password"
          get "create_search_password"
          get "is_exist_in_search"
          get "search_result_record"
        end
      end
      resources :events
      resources :event_invitations
      resources :newsfeed_activities, only: :index
      resources :userfeed_activities, only: :index
      resources :notification_activities, only: [:index, :update]
      resources :authentications, only: :destroy
      resources :conversations, only: [:index, :show, :update]
      resources :messages, only: [:index, :show, :create]
      resources :notification_counts, only: :show
      resources :likes
      resources :memory_lanes, only: :index
    end

    get '*404' => 'static#error404'
  end

  mount Sidekiq::Web, at: '/sidekiq'

  get '*ember' => 'static#app'

end
