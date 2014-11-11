Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  root  to: 'welcome#index'
  get 'welcome/index', as: 'welcome'


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
  
  resources :profiles, only: [:create, :new, :edit, :update]
  
  
end
                                                                                                                                                         