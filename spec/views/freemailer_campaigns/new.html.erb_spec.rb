require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaigns/new.html.erb" do
  include FreemailerCampaignsHelper
  
  before(:each) do
    assigns[:freemailer_campaign] = stub_model(FreemailerCampaign,
      :new_record? => true,
      :subject => "value for subject",
      :title => "value for title",
      :body_template => "value for body_template",
      :sender_id => 1
    )
  end

  it "renders new freemailer_campaign form" do
    render
    
    response.should have_tag("form[action=?][method=post]", freemailer_campaigns_path) do
      with_tag("textarea#freemailer_campaign_subject[name=?]", "freemailer_campaign[subject]")
      with_tag("input#freemailer_campaign_title[name=?]", "freemailer_campaign[title]")
      with_tag("textarea#freemailer_campaign_body_template[name=?]", "freemailer_campaign[body_template]")
      with_tag("input#freemailer_campaign_sender_id[name=?]", "freemailer_campaign[sender_id]")
    end
  end
end


