Rails.application.routes.draw do
  devise_for :users
  get 'rooms/show/:id', to: 'rooms#show'
  get 'rooms/new'
  post 'rooms', to: "rooms#create"
  delete 'rooms/:id', to: "rooms#destroy"
  post 'games/edit/:id', to: 'games#edit'
  root to: 'static_pages#index'
end
