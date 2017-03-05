Rails.application.routes.draw do
  devise_for :users
  resources :admin, only: [:index]
  resources :trainer, only: [:index]
  root 'home#index'
end
