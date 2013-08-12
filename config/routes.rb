BitcoinBank::Application.routes.draw do

  devise_for :users

  resources :invoices, :only => [:index, :new, :create, :show, :destroy]

  resource :user, :only => [:edit, :update] do
    get :ga_otp_configuration
    post :reset_ga_otp_secret
    put :update_password
    get :edit_password

    resources :yubikeys, :only => [:index, :create, :destroy]
    resources :bank_accounts, :only => [:index, :create, :destroy]
    resources :tickets do
      resources :comments, :only => :create
      member do
        post :close
        post :reopen
        post :solve
      end
    end
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  # These routes need some loving :/
  resource :chart, :path => "charts", :only => [] do
    get :price
  end

  resource :account, :only => [:show] do
    match '/balance/:currency',
      :action => 'balance',
      :as => 'balance',
      :only => :get

    get :deposit
    get :pecunix_deposit_form

    resources :transfers, :only => [:index, :new, :create, :show]

    resources :trades,
      :only => [:index]

    resources :invoices

    resources :trade_orders, :only => [:index, :new, :create, :destroy] do
      post :activate
    end
  end

  match "/s/:name" => "static_pages#show", :as => :static

  match '/third_party_callbacks/:action',
    :controller => :third_party_callbacks

  namespace :admin do
    %w{ announcements yubikeys static_pages currencies tickets comments }.each { |r| resources(r.to_sym) {as_routes} }

    resources :pending_transfers do
      as_routes

      member do
        post :process_tx
      end
    end

    resources :users do
      as_routes

      member do
        get :balances
      end

      resources :account_operations do
        as_routes
      end
    end

    match '/balances', :to => 'informations#balances', :as => :balances
  end

  match '/qrcode/:data.png' => 'qrcodes#show', :as => :qrcode

  match '/order_book' => 'trade_orders#book'

  match '/trades' => 'trades#all_trades'

  match '/ticker' => 'trades#ticker'

  match '/economy' => 'informations#economy', :as => :economy

  match '/support' => 'informations#support', :as => :support

  root :to => 'informations#welcome'
end
