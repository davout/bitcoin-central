BitcoinBank::Application.routes.draw do
  resources :invoices, :only => [:index, :new, :create, :show, :destroy]

  resource :user, :only => [:edit, :update] do
    get :otp_configuration
    post :reset_otp_secret
    resources :addresses, :only => [:create]
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  # These routes need some loving :/
  resource :chart, :path => "charts", :only => [] do
    get :price
  end

  resource :account, :only => [:show] do
    get :balance

    resources :transfers, :only => [:index, :new, :create] do
      collection do
        get :deposit
        get :pecunix_deposit_form
      end
    end
    
    resources :trades, 
      :only => [:index]
    
    resources :invoices

    resources :trade_orders, :only => [:index, :new, :create, :destroy] do
      collection do
        get :book
      end
    end
  end

  match '/third_party_callbacks/:action',
    :controller => :third_party_callbacks

  namespace :admin do
    %w{transfers users}.each { |r| resources(r.to_sym) {as_routes} }

    match '/balances', :to => 'admin/informations#balances', :as => :balances
  end

  match '/trades' => 'trades#all_trades'

  match '/ticker' => 'trades#ticker'

  match '/frequently_asked_questions' => 'informations#faq', :as => :faq

  match '/economy' => 'informations#economy', :as => :economy

  match '/support' => 'informations#support', :as => :support

  root :to => 'informations#welcome'
end
