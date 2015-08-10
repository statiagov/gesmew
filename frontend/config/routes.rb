Gesmew::Core::Engine.add_routes do
  root :to => 'home#index'

  get '/unauthorized', :to => 'home#unauthorized', :as => :unauthorized
end
