Glistro::Application.routes.draw do

  # splash page
  root :to => "home#index"

  # devise routes
  devise_for :users

  # normal ol' resources
  resources :slideshows do
    resources :slides, :only => [:index, :show, :create, :update, :destroy]
  end

  # image uploader routes
  match 'upload'     => 'upload#create',  :via => [:post]
  match 'upload/:id' => 'upload#show',    :via => [:get]
  match 'upload/:id' => 'upload#destroy', :via => [:delete]

  # static page routing
  match 'static/:action' => 'static#:action'

end
