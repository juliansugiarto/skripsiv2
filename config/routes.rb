Rails.application.routes.draw do
  root to: 'home#index'
  #root to: 'visitors#index'
  devise_for :users
  resources :users
end
