Rails.application.routes.draw do

  root 'home#index'

  resources :users, :only => [:index, :new, :create]

  resources :products, :except => [:new]

  get '/products/:id/reviews/new' => 'reviews#new' , as: "new_review"
  post '/products/:id/reviews' => 'reviews#create', as: "product_review"
  get '/users/:id/products' => 'products#show_seller_products', as: 'user_product'
  patch '/products/:id/retire' => 'products#retire', as: 'retire_product'

  get '/products/animal/:animal' => 'products#show_animal', as: 'product_animal'
  get '/products/category/:category' => 'products#show_category', as: 'product_category'
  get '/products/:full_name/:id' => 'products#show_merchant', as: 'product_merchant'
  get '/users/:id/products/new' => 'products#new', as: 'new_product'
  post '/users/:id/products' => 'products#create'
  patch '/users/:user_id/products' => 'products#update', as: 'update_product'

  resources :orders

  get '/users/:id/orders' => 'orders#show_seller_orders', as: 'show_seller_orders'
  get '/users/:id/orders/seller_items' => 'orders#seller_items', as: 'seller_items'
  get '/users/:id/orders/:order_id' => 'orders#order_deets', as: 'order_deets'

  resources :orderitems

  get 'orders/order_fulfillment' => 'orders#index', as: 'order_fulfillment'
  patch '/orderitems/:id/shipped' => 'orderitems#shipped', as: 'shipped'

  resources :sessions, :only => [:new, :create]
  get "/logout" => "sessions#destroy"
  get "/orders/:id/checkout" => 'orders#checkout', as: 'order_checkout'
  post "/orders/:id/shipping_price" => 'orders#shipping_price', as: 'update_with_shipping_price'
  patch "/orders/:id/checkout" => "orders#checkout"
  get '/orders/:id/confirmation' => 'orders#confirmation', as: "order_confirmation"



end
