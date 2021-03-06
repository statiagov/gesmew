Gesmew::Core::Engine.add_routes do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :establishments

      resources :option_types do
        resources :option_values
      end
      resources :option_values

      resources :option_values, only: :index

      concern :inspection_routes do
        resources :inspectors
        resources :scopes, controller: 'inspections/scopes'
        resources :assessments, controller: 'inspections/assessments'
        resources :establishments, controller: 'inspections/establishments'
      end

      resources :inspections, concerns: :inspection_routes do
        member do
          put :advance
        end
      end

      resources :rubrics

      resources :users do
        resources :credit_cards, only: [:index]
      end
    end

    match 'v:api/*path', to: redirect("/api/v1/%{path}"), via: [:get, :post, :put, :patch, :delete]
    match '*path', to: redirect("/api/v1/%{path}"), via: [:get, :post, :put, :patch, :delete]
  end
end
