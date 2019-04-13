Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  resources :users, only: [:index, :show]
  resources :friends, only: [:index]
  resources :friend_requests, only: [:create, :update, :destroy]
  resources :friendships, only: [:create, :destroy]
  get 'guest/new', to: 'users#guest_new'
  post 'guest/create', to: 'users#guest_create'
  get 'rooms/update_score_board'
  get 'rooms/close_room'
  get 'rooms/exist_room'
  resources :rooms
  post 'games/edit/:id', to: 'games#edit'
  post 'chats/create'
  get 'about', to: 'static_pages#about'
  root to: 'static_pages#index'
end
