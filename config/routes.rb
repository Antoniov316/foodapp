Rails.application.routes.draw do


  root 'pages#home_3'


  devise_for :users,
             path: '',
             path_names: {sign_in: 'login', sign_out: 'logout', edit: 'profile', sign_up: 'registration'},
             controllers: {omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations'}

  resources :users, only: [:show,:index] do
    member do
      post '/verify_phone_number' => 'users#verify_phone_number'
      patch '/update_phone_number' => 'users#update_phone_number'
    end
  end



  resources :foods, except: [:edit] do
    member do
      get 'listing'
      get 'pricing'
      get 'description'
      get 'photo_upload'
      get 'ingredients'
      get 'diets'
      get 'location'
      get 'preload'
      get 'preview'




    end
    resources :photos, only: [:create, :destroy]
    resources :orders, only: [:create]
    resources :calendars


  end

  resources :foodie_reviews, only: [:create, :destroy]
  resources :chef_reviews, only: [:create, :destroy]


  get '/your_meals' => 'orders#your_meals'
  get '/your_orders' => 'orders#your_orders'
  get '/meals_sold' => 'orders#meals_sold'

  post '/cart' => 'orders#cart'

  get '/remove_product_from_session' => 'orders#remove_product_from_session'


  get '/my_cart' => 'orders#my_cart'
  get 'search' => 'pages#search'
  
  get '/home3' => 'pages#home_3'

  #------ Second level tutorial -----

  get 'dashboard' => 'dashboards#index'

  resources :orders, only: [:approve, :decline, :show] do
    member do
      post '/approve' => "orders#approve"
      post '/decline' => "orders#decline"

    end
  end

  get '/host_calendar' => 'calendars#host'
  get '/payment_method' => 'users#payment'
  post '/add_card' => "users#add_card"

  get '/payout_method' => "users#payout"
  post '/process_payment' => "users#process_payment"

   get 'payment-thanks', to: 'users#thanks', as: 'payment_thanks'

  get '/read_notification', to: 'messages#read_notification', as: 'read_notification'
  get '/notifications', to: 'messages#notifications', as: 'notifications'
  resource :payment_setting, only: :show do
    member do
      get :connect_with_stripe
      get :update_stripe_merchant_details
    end
  end

  mount ActionCable.server => '/cable'
  get 'users/:id/new_message' ,to: 'messages#new_message', as: 'new_message'
  resources :messages, only:[:create, :index]
  post '/followed' ,to: 'users#followed', as: 'followed'

end
