ActionController::Routing::Routes.draw do |map|
  map.resources :contact_carts, :path_prefix => '/admin' do |cart|
    cart.remove_contact 'remove_contact', :method => 'get', :controller => 'contact_carts', :action => 'remove_contact'
  end

  map.resources :freemailer_campaign_contacts, :path_prefix => '/admin'
  map.freemailer_campaign_clear_active 'freemailer_campaigns/clear_active', :path_prefix => '/admin', :controller => 'freemailer_campaigns', 
    :action => 'clear_active', :method => 'get'
  map.resources :freemailer_campaigns, :path_prefix => '/admin' do |campaign|
    campaign.make_active 'make_active', :controller => 'freemailer_campaigns', 
      :action => 'make_active', :method => 'get'
    campaign.send_campaign      'send', :controller => 'freemailer_campaigns', 
      :action => 'send_campaign',        :method => 'get'
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
  map.resources :tags
  map.resources :notes

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
