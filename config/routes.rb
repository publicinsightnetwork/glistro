Glistro::Application.routes.draw do

  # devise routes
  devise_for :users

  # splash page
  root :to => "home#index"

end
