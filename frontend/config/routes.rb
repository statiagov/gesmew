Gesmew::Core::Engine.add_routes do
  root :to => redirect('/login')

  get '/unauthorized', :to => 'home#unauthorized', :as => :unauthorized
end
