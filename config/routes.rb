Rails.application.routes.draw do
  devise_for :users
  get 'rooms/show/:id', to: 'rooms#show', as: :room
  get 'rooms/new'
  post 'rooms', to: "rooms#create"
  delete 'rooms/:id', to: "rooms#destroy"
  post 'games/edit/:id', to: 'games#edit'
  get 'join/:id', to: 'rooms#edit'
  post 'join/:id', to: 'rooms#update'
  root to: 'static_pages#index'
end
