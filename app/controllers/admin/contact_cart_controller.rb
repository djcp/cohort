class ContactCartsController < Admin::BaseController
  # GET /contact_carts
  # GET /contact_carts.xml
  def index
    @contact_carts = ContactCart.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contact_carts }
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
    @contact_cart = ContactCart.find(params[:id])
    @contact_cart.user.active_contact_cart = nil
    @contact_cart.user.save
    @contact_cart.destroy

    respond_to do |format|
      format.html { redirect_to(params[:return_to] || contact_carts_url) }
      format.xml  { head :ok }
    end
  end
end

Admin::ContactCartController = ContactCartsController
