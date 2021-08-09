Rails.application.routes.draw do

  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "static_pages/home"
    get "static_pages/help"
    get "static_pages/about"
    get "static_pages/contact"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :users do
      member do
        resources :followings, only: :index
        resources :followers, only: :index
      end
    end
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :account_activations, only: :edit

    resources :password_resets, execpt: %i(index show destroy)

    resources :microposts, only: %i(create destroy)
    resources :relationships, only: %i(create destroy)
  end
end
