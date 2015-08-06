Gesmew::Core::Engine.add_routes do
  namespace :admin do
    get '/search/users', to: "search#users", as: :search_users
    get '/search/inspections', to: "search#inspections", as: :search_inspections

    resources :inspections, except: [:show] do
      member do
        get :cart
        post :resend
        get :open_adjustments
        get :close_adjustments
        put :approve
        put :cancel
        put :resume
      end

      resources :state_changes, only: [:index]

      resource :customer, controller: "orders/customer_details"
      resources :customer_returns, only: [:index, :new, :edit, :create, :update] do
        member do
          put :refund
        end
      end

      resources :adjustments
      resources :return_authorizations do
        member do
          put :fire
        end
      end
      resources :payments do
        member do
          put :fire
        end

        resources :log_entries
        resources :refunds, only: [:new, :create, :edit, :update]
      end

      resources :reimbursements, only: [:index, :create, :show, :edit, :update] do
        member do
          post :perform
        end
      end
    end

    resources :establishments do
      resources :images do
        collection do
          post :update_positions
        end
      end
    end

    resource :general_settings do
      collection do
        post :clear_cache
      end
    end

    resources :reports, only: [:index] do
      collection do
        get :sales_total
        post :sales_total
      end
    end

    resources :roles

    resources :users do
      member do
        get :addresses
        put :addresses
        put :clear_api_key
        put :generate_api_key
        get :items
        get :inspection
      end
    end
  end

  get '/admin', to: 'admin/root#index', as: :admin
end
