Rails.application.routes.draw do
  root  'welcome#index'
  get 'welcome/index', as: 'welcome'

  devise_for :users
  resources :users # do
#     collection do
#       match('search' => 'user#search', via [:get, :post], as: :search)
#     end
#   end
  
  
end
