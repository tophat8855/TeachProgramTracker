Rails.application.routes.draw do
  devise_for :trainers
  devise_for :admins
  devise_for :users
  resources :admin, only: [:index]
  resources :trainer, only: [:index]
  root 'home#index'
end
