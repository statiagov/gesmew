Gesmew::Core::Engine.add_routes do
  namespace :admin do
    get '/search/users', to: "search#users", as: :search_users
    get '/search/establishments', to: "search#establishments", as: :search_establishments
    get '/search/inspection_scopes', to: "search#inspection_scopes", as: :search_inspection_scopes

    resources :inspections, except: [:show] do
      member do
        get :process_inspection
        get :grade_and_comment
        post :resend
        put :approve
        put :cancel
        put :resume
      end

      resources :state_changes, only: [:index]
      resources :comments, controller: "inspections/comments"

      resources :adjustments
    end

    resources :inspection_scopes


    resources :establishments

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

    resources :establishment_types

    resources :roles

    resources :users , controller: "users" do
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
