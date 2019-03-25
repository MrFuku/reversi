Rails.application.routes.draw do
  devise_for :users
  get 'rooms/show'
  post 'games/edit'
  root to: 'static_pages#index'
end
