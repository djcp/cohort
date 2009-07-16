class FreemailerCampaignContactsController < ApplicationController
  before_filter :is_admin
  # GET /freemailer_campaign_contacts
  # GET /freemailer_campaign_contacts.xml
  def index
    @freemailer_campaign_contacts = FreemailerCampaignContact.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @freemailer_campaign_contacts }
    end
  end

  # GET /freemailer_campaign_contacts/1
  # GET /freemailer_campaign_contacts/1.xml
  def show
    @freemailer_campaign_contact = FreemailerCampaignContact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @freemailer_campaign_contact }
    end
  end

  # GET /freemailer_campaign_contacts/new
  # GET /freemailer_campaign_contacts/new.xml
  def new
    @freemailer_campaign_contact = FreemailerCampaignContact.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @freemailer_campaign_contact }
    end
  end

  # GET /freemailer_campaign_contacts/1/edit
  def edit
    @freemailer_campaign_contact = FreemailerCampaignContact.find(params[:id])
  end

  # POST /freemailer_campaign_contacts
  # POST /freemailer_campaign_contacts.xml
  def create
    @freemailer_campaign_contact = FreemailerCampaignContact.new(params[:freemailer_campaign_contact])

    respond_to do |format|
      if @freemailer_campaign_contact.save
        flash[:notice] = 'FreemailerCampaignContact was successfully created.'
        format.html { redirect_to(@freemailer_campaign_contact) }
        format.xml  { render :xml => @freemailer_campaign_contact, :status => :created, :location => @freemailer_campaign_contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @freemailer_campaign_contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /freemailer_campaign_contacts/1
  # PUT /freemailer_campaign_contacts/1.xml
  def update
    @freemailer_campaign_contact = FreemailerCampaignContact.find(params[:id])

    respond_to do |format|
      if @freemailer_campaign_contact.update_attributes(params[:freemailer_campaign_contact])
        flash[:notice] = 'FreemailerCampaignContact was successfully updated.'
        format.html { redirect_to(@freemailer_campaign_contact) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @freemailer_campaign_contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /freemailer_campaign_contacts/1
  # DELETE /freemailer_campaign_contacts/1.xml
  def destroy
    @freemailer_campaign_contact = FreemailerCampaignContact.find(params[:id])
    @freemailer_campaign_contact.destroy

    respond_to do |format|
      format.html { redirect_to(freemailer_campaign_contacts_url) }
      format.xml  { head :ok }
    end
  end
end
