Rails.application.routes.draw do
  root  to: 'welcome#index'
  get 'welcome/index', as: 'welcome'

  # devise_scope :user do
  #   get "index", to: "registrations#index", on: :collection
  # end
  # These paths support a modification to Devise's Registrations#edit and Registrations#update
  # actions enble a user to edit another user's profile

  devise_scope :user  do
    get "/account/users/:id" => "devise/registrations#show", as: :userx_registration
    get "/account/users/edit/:id" => "devise/registrations#edit", as: :edit_userx_registration
    put "/account/users/:id" => "devise/registrations#update"
    patch "/account/users/:id" => "devise/registrations#update"
    delete "/account/users/:id" => "devise/registrations#destroy"
  end


  # resources :registrations, only: :index
  
  devise_for :users, path: 'account'

  # devise_for :users, :skip => [:registrations]
  #   as :user do
  #     get 'cancel_user_registration' => 'devise/sessions#new', :as => :new_user_session
  #     post 'signin' => 'devise/sessions#create', :as => :user_session
  #     delete 'signout' => 'devise/sessions#destroy', :as => :destroy_user_session
  #   end




  resources :users
#   devise_scope :user do
#
#     Note we use the route name 'user' for our route extensions (#index & #show), rather than
#     user_registration as the other devise actions use. We do this due to a name
#     conflict , for #create and #show. Devise incorrectly uses user_registration
#     for #create when the standard is to use user_registrations for this action.
#     The name user_registration rightly belongs to #show action.
#     get "/users" => 'registrations#index', as: "users"
#     get "/users/:id" => 'registrations#show', as: "user"
#     get "/users"
#   end
       
  # resources :users # do
#     collection do
#       match('search' => 'user#search', via [:get, :post], as: :search)
#     end
#   end
  
  
end
                                                                                                                                                         