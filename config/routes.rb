Rails.application.routes.draw do
  get "posts/list", to: "posts#list"
  resources :posts 
  get "get_next_five_posts(/:id)", to: "posts#get_next_five_posts"
  get "get_prev_five_posts(/:id)", to: "posts#get_prev_five_posts"

  get "up" => "rails/health#show", as: :rails_health_check
end
