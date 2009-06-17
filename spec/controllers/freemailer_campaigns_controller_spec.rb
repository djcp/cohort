require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaignsController do

  def mock_freemailer_campaign(stubs={})
    @mock_freemailer_campaign ||= mock_model(FreemailerCampaign, stubs)
  end
  
  describe "GET index" do
    it "assigns all freemailer_campaigns as @freemailer_campaigns" do
      FreemailerCampaign.stub!(:find).with(:all).and_return([mock_freemailer_campaign])
      get :index
      assigns[:freemailer_campaigns].should == [mock_freemailer_campaign]
    end
  end

  describe "GET show" do
    it "assigns the requested freemailer_campaign as @freemailer_campaign" do
      FreemailerCampaign.stub!(:find).with("37").and_return(mock_freemailer_campaign)
      get :show, :id => "37"
      assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
    end
  end

  describe "GET new" do
    it "assigns a new freemailer_campaign as @freemailer_campaign" do
      FreemailerCampaign.stub!(:new).and_return(mock_freemailer_campaign)
      get :new
      assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
    end
  end

  describe "GET edit" do
    it "assigns the requested freemailer_campaign as @freemailer_campaign" do
      FreemailerCampaign.stub!(:find).with("37").and_return(mock_freemailer_campaign)
      get :edit, :id => "37"
      assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created freemailer_campaign as @freemailer_campaign" do
        FreemailerCampaign.stub!(:new).with({'these' => 'params'}).and_return(mock_freemailer_campaign(:save => true))
        post :create, :freemailer_campaign => {:these => 'params'}
        assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
      end

      it "redirects to the created freemailer_campaign" do
        FreemailerCampaign.stub!(:new).and_return(mock_freemailer_campaign(:save => true))
        post :create, :freemailer_campaign => {}
        response.should redirect_to(freemailer_campaign_url(mock_freemailer_campaign))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved freemailer_campaign as @freemailer_campaign" do
        FreemailerCampaign.stub!(:new).with({'these' => 'params'}).and_return(mock_freemailer_campaign(:save => false))
        post :create, :freemailer_campaign => {:these => 'params'}
        assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
      end

      it "re-renders the 'new' template" do
        FreemailerCampaign.stub!(:new).and_return(mock_freemailer_campaign(:save => false))
        post :create, :freemailer_campaign => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested freemailer_campaign" do
        FreemailerCampaign.should_receive(:find).with("37").and_return(mock_freemailer_campaign)
        mock_freemailer_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :freemailer_campaign => {:these => 'params'}
      end

      it "assigns the requested freemailer_campaign as @freemailer_campaign" do
        FreemailerCampaign.stub!(:find).and_return(mock_freemailer_campaign(:update_attributes => true))
        put :update, :id => "1"
        assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
      end

      it "redirects to the freemailer_campaign" do
        FreemailerCampaign.stub!(:find).and_return(mock_freemailer_campaign(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(freemailer_campaign_url(mock_freemailer_campaign))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested freemailer_campaign" do
        FreemailerCampaign.should_receive(:find).with("37").and_return(mock_freemailer_campaign)
        mock_freemailer_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :freemailer_campaign => {:these => 'params'}
      end

      it "assigns the freemailer_campaign as @freemailer_campaign" do
        FreemailerCampaign.stub!(:find).and_return(mock_freemailer_campaign(:update_attributes => false))
        put :update, :id => "1"
        assigns[:freemailer_campaign].should equal(mock_freemailer_campaign)
      end

      it "re-renders the 'edit' template" do
        FreemailerCampaign.stub!(:find).and_return(mock_freemailer_campaign(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested freemailer_campaign" do
      FreemailerCampaign.should_receive(:find).with("37").and_return(mock_freemailer_campaign)
      mock_freemailer_campaign.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the freemailer_campaigns list" do
      FreemailerCampaign.stub!(:find).and_return(mock_freemailer_campaign(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(freemailer_campaigns_url)
    end
  end

end
