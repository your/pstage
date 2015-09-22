Rails.application.routes.draw do
    
  resources :categories
  resources :partners 
  resources :offices
  resources :partnerships
  resources :representatives
  resources :map, only: :index  
  
end
