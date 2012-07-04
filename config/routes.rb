Glistro::Application.routes.draw do

  # splash page
  root :to => "home#index"

  # devise routes
  devise_for :users

  # normal ol' resources
  resources :slideshows

  # static page routing
  match 'static/:action' => 'static#:action'

end
