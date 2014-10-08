Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  root  to: 'welcome#index'
  get 'welcome/index', as: 'welcome'

  # devise_scope :user do
  #   get "index", to: "registrations#index", on: :collection
  # end
  # These paths support a modification to Devise's Registrations#edit and Registrations#update
  # actions enble a user to edit another user's profile

  devise_scope :user  do
    get "/account/users" => "devise/registrations#index", as: :users
    put "account/users" => "devise/registrations#index", as: :search_users
    get "/account/users/:id" => "devise/registrations#show", as: :userx_registration
    get "/account/users/edit/:id" => "devise/registrations#edit", as: :edit_userx_registration
    put "/account/users/:id" => "devise/registrations#update"
    patch "/account/users/:id" => "devise/registrations#update"
    delete "/account/users/:id" => "devise/registrations#destroy"
  end


  devise_for :users, path: 'account'
       
  # resources :users # do
#     collection do
#       match('search' => 'user#search', via [:get, :post], as: :search)
#     end
#   end
  
  
end
                                                                                                                                                         