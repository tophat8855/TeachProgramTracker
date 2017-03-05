Rails.application.routes.draw do
  devise_for :users, :path_prefix => 'my'
  resources :users
  root 'home#index'
end
