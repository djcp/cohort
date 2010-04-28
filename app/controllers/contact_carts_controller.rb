class ContactCartsController < ApplicationController
  before_filter :is_admin

  # (GET) make_active assigns a user's active contact cart by finding the contact cart with id <tt>params[:contact_cart_id]</tt> so long as it belongs to the user or is set as global.
  def make_active
    @session_user.active_contact_cart = ContactCart.find(params[:contact_cart_id], :conditions => ["user_id = ? or global = true",@session_user.id])
    @session_user.save
    flash[:notice] = "Contact Cart has been made active."
    redirect_to contact_carts_url
  end

  # (GET) clear_active sets the user's active contact cart to <tt>nil</tt>.
  def clear_active
    flash[:notice] = "Active contact cart cleared."
    @session_user.active_contact_cart = nil
    @session_user.save
    redirect_to contact_carts_url
  end
  
  def edit
    @contact_cart = ContactCart.find(params[:id])
  end

  # (GET) index is different from a normal index in that it provides two sets of ContactCarts to the user: 
  # * Those owned by the user and
  # * those not owned by the user, but marked global
  def index
    carts = ContactCart.all(:conditions => ["user_id = ? or global = true",@session_user.id]).group_by {|cart| cart.user == @session_user}
    @my_contact_carts = carts[true]
    @global_contact_carts = carts[false]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contact_carts }
    end
  end

  def show
    @contact_cart = ContactCart.find_by_id(params[:id], :conditions => ["user_id = ? or global = true",@session_user.id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact_cart }
    end
  end
  
  # (POST) create is different from the normal RESTful create in that it handles both creation and updates.
  #
  # create will either
  # * Update the current user's active contact cart, or
  # * Create a new cart for the user (and set it as active)
  # 
  # create will then add all selected contacts (populated via Javascript)
  def create
    if request.post?
      @contact_cart = @session_user.active_contact_cart || ContactCart.new(:user => @session_user, :title => params[:title])
      if @contact_cart.valid?
        new_contacts = Contact.find_all_by_id(params[:contact_ids]) - @contact_cart.contacts
        @contact_cart.contacts << new_contacts
        @contact_cart.save
        @session_user.active_contact_cart = @contact_cart
        @session_user.save
        flash[:notice] = 'Contact cart created/updated.'
      else
        flash[:error] = "We couldn't create the cart."
      end
    end
    manage_destination 
  end

  # (POST) remove_contact removes the contact with id of <tt>params[:contact_to_remove_id]</tt> from the user's active contact cart
  def remove_contact
    if request.post?
      @contact_cart = @session_user.active_contact_cart
      @contact_cart.contacts.delete( Contact.find(params[:contact_to_remove_id]))
      @contact_cart.save
      manage_destination 
    end
  end
  
  def destroy
    if @contact_cart = ContactCart.find_by_id(params[:id], :conditions => ["user_id = ?",@session_user.id])
      @contact_cart.user.active_contact_cart = nil
      @contact_cart.user.save
      @contact_cart.destroy
      flash[:notice] = 'Contact cart destroyed.'
    else
      flash[:error] = 'Contact cart not destroyed. Are you trying to delete someone else\'s cart?'
    end
    respond_to do |format|
      format.html { manage_destination }
      format.xml  { head :ok }
    end
  end
end
