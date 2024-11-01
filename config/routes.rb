Rails.application.routes.draw do
  get "posts/list", to: "posts#list"
  resources :posts 

  get "up" => "rails/health#show", as: :rails_health_check
end
