Rails.application.routes.draw do
  devise_for :users, path_prefix: 'my'
  post 'users/invite', to: 'users#invite'

  root 'home#index'

  resources :users
  resources :procedures
  resources :residency_locations
end
