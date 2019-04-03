Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:index, :show]
  resources :friends, only: [:index]
  resources :friend_requests, only: [:create, :update, :destroy]
  resources :friendships, only: [:create, :destroy]
  resources :rooms
  post 'games/edit/:id', to: 'games#edit'
  post 'chats/create'
  root to: 'static_pages#index'
end
