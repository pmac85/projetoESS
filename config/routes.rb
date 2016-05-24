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
  resources :teams
  resources :players,             only: [:index, :show]
  resources :leagues,             only: [:index, :show, :new, :create]
  resources :journeys
  get 'teams/:id/transfers' => 'teams#transfers',       :as => 'transfers_get_team'
  post 'teams/:id/transfers' => 'teams#transfers',       :as => 'transfers_team'
  post 'teams/:id/strategy' => 'teams#changeStrategy'
  post 'teams/:id/transfer' => 'teams#transfer'
  post 'teams/:id/edit'     => 'teams#edit'
  post 'teams/:id/choose'   => 'teams#choose_team',     :as => 'choose_team'
  get 'journeys/:id/index'   => 'journeys#index', :as => 'journeys_show'

end
