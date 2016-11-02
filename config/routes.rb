Rails.application.routes.draw do
  resources :designers
  root to: 'home#index'
  #root to: 'visitors#index'
  devise_for :users
  resources :users
  
  get '/dashboard' => 'dashboard#show', as: :dashboard_show

end
