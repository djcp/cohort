class Admin::ContactCartController < ApplicationController
  before_filter :is_admin
  # GET /contact_carts
  # GET /contact_carts.xml
  def index
    @contact_carts = ContactCart.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contact_carts }
    end
  end

  # GET /contact_carts/1
  # GET /contact_carts/1.xml
  # def show
  #   @contact_cart = ContactCart.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.xml  { render :xml => @contact_cart }
  #   end
  # end

  # GET /contact_carts/new
  # GET /contact_carts/new.xml
  # def new
  #   @contact_cart = ContactCart.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @contact_cart }
  #   end
  # end

  # GET /contact_carts/1/edit
  # def edit
  #   @contact_cart = ContactCart.find(params[:id])
  # end

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
    # @contact_cart = ContactCart.new(params[:contact_cart])
    # 
    # respond_to do |format|
    #   if @contact_cart.save
    #     flash[:notice] = 'ContactCart was successfully created.'
    #     format.html { redirect_to(@contact_cart) }
    #     format.xml  { render :xml => @contact_cart, :status => :created, :location => @contact_cart }
    #   else
    #     format.html { render :action => "new" }
    #     format.xml  { render :xml => @contact_cart.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # PUT /contact_carts/1
  # PUT /contact_carts/1.xml
  # def update
  #   @contact_cart = ContactCart.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @contact_cart.update_attributes(params[:contact_cart])
  #       flash[:notice] = 'ContactCart was successfully updated.'
  #       format.html { redirect_to(@contact_cart) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @contact_cart.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /contact_carts/1
  # DELETE /contact_carts/1.xml
  def destroy
    @contact_cart = ContactCart.find(params[:id])
    @contact_cart.destroy

    respond_to do |format|
      format.html { redirect_to(contact_carts_url) }
      format.xml  { head :ok }
    end
  end
end
