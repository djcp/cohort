class ContactCartsController < Admin::BaseController

  def make_active
    @session_user.active_contact_cart = ContactCart.find(params[:contact_cart_id], :conditions => ["user_id = ? or global = true",@session_user.id])
    @session_user.save
    flash[:notice] = "Contact Cart has been made active."
    redirect_to contact_carts_url
  end

  def clear_active
    flash[:notice] = "Active contact cart cleared."
    @session_user.active_contact_cart = nil
    @session_user.save
    redirect_to contact_carts_url
  end
  
  def index
    carts = ContactCart.all(:conditions => ["user_id = ? or global = true",@session_user.id]).group_by {|cart| cart.user == @session_user}
    @my_contact_carts = carts[true]
    @global_contact_carts = carts[false]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contact_carts }
    end
  end

  # GET /freemailer_campaigns/1
  # GET /freemailer_campaigns/1.xml
  def show
    @contact_cart = ContactCart.find_by_id(params[:id], :conditions => ["user_id = ? or global = true",@session_user.id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact_cart }
    end
  end
  
  # POST /contact_carts
  # POST /contact_carts.xml
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
    redirect_to params[:return_to] and return     
  end

  def remove_contact
    if request.post?
      @contact_cart = @session_user.active_contact_cart
      @contact_cart.contacts.delete( Contact.find(params[:contact_to_remove_id]))
      @contact_cart.save
      redirect_to params[:return_to] and return
    end
  end
  # DELETE /contact_carts/1
  # DELETE /contact_carts/1.xml
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
      format.html { redirect_to(params[:return_to] || contact_carts_url) }
      format.xml  { head :ok }
    end
  end
end

Admin::ContactCartController = ContactCartsController
