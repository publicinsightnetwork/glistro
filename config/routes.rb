Glistro::Application.routes.draw do

  # devise routes
  devise_for :users

  # splash page
  root :to => "home#index"

  # static page routing
  match 'static/:action' => 'static#:action'

end
