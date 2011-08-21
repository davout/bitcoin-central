BitcoinBank::Application.routes.draw do
  resources :tickets

  resources :invoices, :only => [:index, :new, :create, :show, :destroy]

  resource :user, :only => [:edit, :update] do
    get :ga_otp_configuration
    post :reset_ga_otp_secret

    resources :yubikeys, :only => [:index, :create, :destroy]
    resources :bank_accounts, :only => [:index, :create, :destroy]
    resources :tickets
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  # These routes need some loving :/
  resource :chart, :path => "charts", :only => [] do
    get :price
  end

  resource :account, :only => [:show] do
    get :balance
    get :deposit
    get :pecunix_deposit_form
    
    resources :transfers, :only => [:index, :new, :create, :show] 
    
    resources :trades, 
      :only => [:index]
    
    resources :invoices

    resources :trade_orders, :only => [:index, :new, :create, :destroy] do
      collection do
        get :book
      end
    end
  end

  match "/s/:name" => "static_pages#show", :as => :static
  
  match '/third_party_callbacks/:action',
    :controller => :third_party_callbacks

  namespace :admin do
    %w{transfers users announcements yubikeys static_pages currencies}.each { |r| resources(r.to_sym) {as_routes} }

    match '/balances', :to => 'informations#balances', :as => :balances
  end

  match '/trades' => 'trades#all_trades'

  match '/ticker' => 'trades#ticker'

  match '/economy' => 'informations#economy', :as => :economy

  match '/support' => 'informations#support', :as => :support

  root :to => 'informations#welcome'
end
