Rails.application.routes.draw do
  devise_for :users, :path_prefix => 'my'
  resources :users
  post 'users/invite', :to => 'users#invite'
  root 'home#index'
end
