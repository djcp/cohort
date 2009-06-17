require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaignContactsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "freemailer_campaign_contacts", :action => "index").should == "/freemailer_campaign_contacts"
    end
  
    it "maps #new" do
      route_for(:controller => "freemailer_campaign_contacts", :action => "new").should == "/freemailer_campaign_contacts/new"
    end
  
    it "maps #show" do
      route_for(:controller => "freemailer_campaign_contacts", :action => "show", :id => "1").should == "/freemailer_campaign_contacts/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "freemailer_campaign_contacts", :action => "edit", :id => "1").should == "/freemailer_campaign_contacts/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "freemailer_campaign_contacts", :action => "create").should == {:path => "/freemailer_campaign_contacts", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "freemailer_campaign_contacts", :action => "update", :id => "1").should == {:path =>"/freemailer_campaign_contacts/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "freemailer_campaign_contacts", :action => "destroy", :id => "1").should == {:path =>"/freemailer_campaign_contacts/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/freemailer_campaign_contacts").should == {:controller => "freemailer_campaign_contacts", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/freemailer_campaign_contacts/new").should == {:controller => "freemailer_campaign_contacts", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/freemailer_campaign_contacts").should == {:controller => "freemailer_campaign_contacts", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/freemailer_campaign_contacts/1").should == {:controller => "freemailer_campaign_contacts", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/freemailer_campaign_contacts/1/edit").should == {:controller => "freemailer_campaign_contacts", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/freemailer_campaign_contacts/1").should == {:controller => "freemailer_campaign_contacts", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/freemailer_campaign_contacts/1").should == {:controller => "freemailer_campaign_contacts", :action => "destroy", :id => "1"}
    end
  end
end
