class FreemailerCampaignsController < ApplicationController
  before_filter :is_admin
  before_filter :only_load_campaigns_user_owns , :only => [:destroy,:update,:show, :edit, :make_active, :send]
  
  def make_active
    @freemailer_campaign.make_active_for_sender
    flash[:notice] = "Campaign has been made active."
    redirect_to freemailer_campaigns_url
  end
  
  def clear_active
    flash[:notice] = "Active campaign cleared."
    @session_user.active_campaign = nil
    @session_user.save
    redirect_to freemailer_campaigns_url
  end
    
  def send_campaign
    campaign = @session_user.active_campaign
    campaign.send_campaign
    flash[:notice] = "Mail Campaign Sent."
    @session_user.active_campaign = nil
    @session_user.save
    redirect_to freemailer_campaigns_url
  end
  
  # GET /freemailer_campaigns
  # GET /freemailer_campaigns.xml
  def index
    @freemailer_campaigns = FreemailerCampaign.find(:all,
      :conditions => { :sender_id => @session_user.id })

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @freemailer_campaigns }
    end
  end

  # GET /freemailer_campaigns/1
  # GET /freemailer_campaigns/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @freemailer_campaign }
    end
  end

  # GET /freemailer_campaigns/1/edit
  def edit
  end

  # POST /freemailer_campaigns
  # POST /freemailer_campaigns.xml
  def create
    @freemailer_campaign = FreemailerCampaign.new(params[:freemailer_campaign])

    respond_to do |format|
      if @freemailer_campaign.save
        flash[:notice] = 'Mailing Campaign was successfully created.'
        format.html { redirect_to(@freemailer_campaign) }
        format.xml  { render :xml => @freemailer_campaign, :status => :created, :location => @freemailer_campaign }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @freemailer_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /freemailer_campaigns/1
  # PUT /freemailer_campaigns/1.xml
  def update
    respond_to do |format|
      if @freemailer_campaign.update_attributes(params[:freemailer_campaign])
        flash[:notice] = 'Mailing Campaign was successfully updated.'
        format.html { redirect_to(@freemailer_campaign) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @freemailer_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /freemailer_campaigns/1
  # DELETE /freemailer_campaigns/1.xml
  def destroy
    @freemailer_campaign.destroy

    respond_to do |format|
      format.html { redirect_to(freemailer_campaigns_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def only_load_campaigns_user_owns
    if not params[:id]
      params[:id] = params[:freemailer_campaign_id]
    end
    @freemailer_campaign = FreemailerCampaign.find(params[:id])
    if @freemailer_campaign.sender != @session_user
      flash[:error] = "You do not own the freemailer campaign you are trying to access"
      redirect_to freemailer_campaigns_url
    end
  end
end
