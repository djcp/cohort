require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaignContactsController do

  def mock_freemailer_campaign_contact(stubs={})
    @mock_freemailer_campaign_contact ||= mock_model(FreemailerCampaignContact, stubs)
  end
  
  describe "GET index" do
    it "assigns all freemailer_campaign_contacts as @freemailer_campaign_contacts" do
      FreemailerCampaignContact.stub!(:find).with(:all).and_return([mock_freemailer_campaign_contact])
      get :index
      assigns[:freemailer_campaign_contacts].should == [mock_freemailer_campaign_contact]
    end
  end

  describe "GET show" do
    it "assigns the requested freemailer_campaign_contact as @freemailer_campaign_contact" do
      FreemailerCampaignContact.stub!(:find).with("37").and_return(mock_freemailer_campaign_contact)
      get :show, :id => "37"
      assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
    end
  end

  describe "GET new" do
    it "assigns a new freemailer_campaign_contact as @freemailer_campaign_contact" do
      FreemailerCampaignContact.stub!(:new).and_return(mock_freemailer_campaign_contact)
      get :new
      assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
    end
  end

  describe "GET edit" do
    it "assigns the requested freemailer_campaign_contact as @freemailer_campaign_contact" do
      FreemailerCampaignContact.stub!(:find).with("37").and_return(mock_freemailer_campaign_contact)
      get :edit, :id => "37"
      assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created freemailer_campaign_contact as @freemailer_campaign_contact" do
        FreemailerCampaignContact.stub!(:new).with({'these' => 'params'}).and_return(mock_freemailer_campaign_contact(:save => true))
        post :create, :freemailer_campaign_contact => {:these => 'params'}
        assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
      end

      it "redirects to the created freemailer_campaign_contact" do
        FreemailerCampaignContact.stub!(:new).and_return(mock_freemailer_campaign_contact(:save => true))
        post :create, :freemailer_campaign_contact => {}
        response.should redirect_to(freemailer_campaign_contact_url(mock_freemailer_campaign_contact))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved freemailer_campaign_contact as @freemailer_campaign_contact" do
        FreemailerCampaignContact.stub!(:new).with({'these' => 'params'}).and_return(mock_freemailer_campaign_contact(:save => false))
        post :create, :freemailer_campaign_contact => {:these => 'params'}
        assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
      end

      it "re-renders the 'new' template" do
        FreemailerCampaignContact.stub!(:new).and_return(mock_freemailer_campaign_contact(:save => false))
        post :create, :freemailer_campaign_contact => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested freemailer_campaign_contact" do
        FreemailerCampaignContact.should_receive(:find).with("37").and_return(mock_freemailer_campaign_contact)
        mock_freemailer_campaign_contact.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :freemailer_campaign_contact => {:these => 'params'}
      end

      it "assigns the requested freemailer_campaign_contact as @freemailer_campaign_contact" do
        FreemailerCampaignContact.stub!(:find).and_return(mock_freemailer_campaign_contact(:update_attributes => true))
        put :update, :id => "1"
        assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
      end

      it "redirects to the freemailer_campaign_contact" do
        FreemailerCampaignContact.stub!(:find).and_return(mock_freemailer_campaign_contact(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(freemailer_campaign_contact_url(mock_freemailer_campaign_contact))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested freemailer_campaign_contact" do
        FreemailerCampaignContact.should_receive(:find).with("37").and_return(mock_freemailer_campaign_contact)
        mock_freemailer_campaign_contact.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :freemailer_campaign_contact => {:these => 'params'}
      end

      it "assigns the freemailer_campaign_contact as @freemailer_campaign_contact" do
        FreemailerCampaignContact.stub!(:find).and_return(mock_freemailer_campaign_contact(:update_attributes => false))
        put :update, :id => "1"
        assigns[:freemailer_campaign_contact].should equal(mock_freemailer_campaign_contact)
      end

      it "re-renders the 'edit' template" do
        FreemailerCampaignContact.stub!(:find).and_return(mock_freemailer_campaign_contact(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested freemailer_campaign_contact" do
      FreemailerCampaignContact.should_receive(:find).with("37").and_return(mock_freemailer_campaign_contact)
      mock_freemailer_campaign_contact.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the freemailer_campaign_contacts list" do
      FreemailerCampaignContact.stub!(:find).and_return(mock_freemailer_campaign_contact(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(freemailer_campaign_contacts_url)
    end
  end

end
