Rails.application.routes.draw do

  root to: 'projects#index'

  resources :projects

  get "/login", to: "sessions#new"
  get "/logout", to: "sessions#destroy"
  post "/sessions", to: "sessions#create"

end
