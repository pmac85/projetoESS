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

  post 'teams/:id/strategy' => 'teams#changeStrategy'
  post 'teams/:id/transfer' => 'teams#transfer'

end
