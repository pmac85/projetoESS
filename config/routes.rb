Rails.application.routes.draw do
  root 'static_pages#home'
  get 'static_pages/home'

  get 'static_pages/rules'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

end
