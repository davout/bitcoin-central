BitcoinBank::Application.routes.draw do
  resource :user, :only => [:new, :create, :edit, :update] do
    resources :addresses, :only => [:index, :show, :create]

    get :balance
  end

  resource :session

  resource :chart, :path => "charts", :only => [] do
    get :price
  end

  resource :account, :only => [:show] do
    resources :transfers, :only => [:index]
    resources :bitcoin_transfers, :only => [:new, :create]
    resources :liberty_reserve_transfers, :only => [:new, :create] do

      # Liberty Reserve callbacks
      collection do
        post :lr_create_from_sci
        get :lr_transfer_success
        get :lr_transfer_fail
      end

      resources :invoices
    end

    # Should be *cancel/close* instead of destroy
    resources :trade_orders, :only => [:index, :new, :create, :destroy] do
      collection do
        get :book
      end
    end

    resources :trades, :only => [:index, :new, :create, :destroy]
  end

  resources :trades, :only => [] do
    collection do
      get :all_trades
      get :ticker
      get :statistics
    end
  end

  namespace :admin do
    resource :server, :only => [] do
      get :infos
    end
  end

  match '/frequently_asked_questions' => 'informations#faq',
    :as => :faq

  match '/economy' => 'informations#economy',
    :as => :economy

  match '/support' => 'informations#support',
    :as => :support

  # TODO : Replace me
  root :to => 'informations#welcome'
end
