Rails.application.routes.draw do
  resources :designers
  root to: 'home#index'
  #root to: 'visitors#index'
  devise_for :users
  resources :users
  
  get '/dashboard' => 'dashboard#show', as: :dashboard_show
  get '/dashboard/ga' => 'dashboard#ga', as: :dashboard_ga_show
  get '/dashboard/ajax_data' => 'dashboard#ajax_data'
  get '/dashboard/ajax_data_dist' => 'dashboard#ajax_data_dist'

end
