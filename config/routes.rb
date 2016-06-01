Rails.application.routes.draw do

  root 'static_pages#home'

  get    'rules'   => 'static_pages#rules'
  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :teams,               except: [:new, :destroy]
  resources :players,             only: [:index, :show]
  resources :leagues,             only: [:index, :show, :new, :create, :destroy]
  resources :journeys,            only: [:index]
  resources :games,               only: [:show]
  get 'teams/:id/transfers' => 'teams#transfers',       :as => 'transfers_get_team'
  post 'teams/:id/transfers' => 'teams#transfers',       :as => 'transfers_team'
  post 'teams/:id/strategy' => 'teams#changeStrategy'
  post 'teams/:id/transfer' => 'teams#transfer'
  post 'teams/:id/edit'     => 'teams#edit'
  post 'teams/:id/choose'   => 'teams#choose_team',     :as => 'choose_team'
  get 'teams/:id/drop'      => 'teams#drop_user', :as => 'drop_team'
  post 'games/:id/show'     => 'games#show', :as =>'game_show'
  get 'journeys/:id/index'  => 'journeys#index', :as => 'journeys_show'
  get 'journeys/:id/close'  => 'journeys#close', :as => 'close_journey'
  get 'leagues/:id/close_all'  => 'leagues#close_all', :as => 'close_all_journeys'

end
