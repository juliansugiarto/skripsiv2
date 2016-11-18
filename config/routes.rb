Rails.application.routes.draw do
  resources :designers
  root to: 'home#index'
  #root to: 'visitors#index'
  devise_for :users
  resources :users
  
  get '/dashboard' => 'dashboard#show', as: :dashboard_show
  get '/dashboard/ga' => 'dashboard#ga', as: :dashboard_ga_show
  get '/dashboard/ajax_data' => 'dashboard#ajax_data'
  get '/dashboard/new_ch_contest' => 'dashboard#new_ch_contest'
  get '/dashboard/contest_status' => 'dashboard#contest_status'
  get '/dashboard/contest_package' => 'dashboard#contest_package'
  get '/dashboard/contest_package_sales' => 'dashboard#contest_package_sales'
  get '/dashboard/potential' => 'dashboard#potential'

end
