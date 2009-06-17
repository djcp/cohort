require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaignsController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "freemailer_campaigns", :action => "index").should == "/freemailer_campaigns"
    end
  
    it "maps #new" do
      route_for(:controller => "freemailer_campaigns", :action => "new").should == "/freemailer_campaigns/new"
    end
  
    it "maps #show" do
      route_for(:controller => "freemailer_campaigns", :action => "show", :id => "1").should == "/freemailer_campaigns/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "freemailer_campaigns", :action => "edit", :id => "1").should == "/freemailer_campaigns/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "freemailer_campaigns", :action => "create").should == {:path => "/freemailer_campaigns", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "freemailer_campaigns", :action => "update", :id => "1").should == {:path =>"/freemailer_campaigns/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "freemailer_campaigns", :action => "destroy", :id => "1").should == {:path =>"/freemailer_campaigns/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/freemailer_campaigns").should == {:controller => "freemailer_campaigns", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/freemailer_campaigns/new").should == {:controller => "freemailer_campaigns", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/freemailer_campaigns").should == {:controller => "freemailer_campaigns", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/freemailer_campaigns/1").should == {:controller => "freemailer_campaigns", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/freemailer_campaigns/1/edit").should == {:controller => "freemailer_campaigns", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/freemailer_campaigns/1").should == {:controller => "freemailer_campaigns", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/freemailer_campaigns/1").should == {:controller => "freemailer_campaigns", :action => "destroy", :id => "1"}
    end
  end
end
