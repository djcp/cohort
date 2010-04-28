ActionController::Routing::Routes.draw do |map|
  map.contact_cart_clear_active 'contact_cart/clear_active',
    :controller => 'contact_carts', :action => 'clear_active', :method => 'get'
  map.resources :contact_carts do |cart|
    cart.remove_contact 'remove_contact',  :controller => 'contact_carts', :action => 'remove_contact',
      :method => 'put'
    cart.make_active 'make_active', :controller => 'contact_carts', :action => 'make_active', 
      :method => 'get'
  end

  map.freemailer_campaign_clear_active 'freemailer_campaigns/clear_active', 
    :controller => 'freemailer_campaigns', :action => 'clear_active', :method => 'get'
  map.resources :freemailer_campaigns  do |campaign|
    campaign.make_active 'make_active', :action => 'make_active', :method => 'get', 
      :controller => 'freemailer_campaigns'
    campaign.send_campaign      'send', :action => 'send_campaign', :method => 'get',
      :controller => 'freemailer_campaigns'
    campaign.statuses       'statuses', :action => 'statuses',
      :controller => 'freemailer_campaigns'
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "/admin/dashboard", :action => :dashboard

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

  map.resources :contacts
  map.resources :contact_carts
  map.resources :tags
  map.resources :notes
  map.resources :saved_searches

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
