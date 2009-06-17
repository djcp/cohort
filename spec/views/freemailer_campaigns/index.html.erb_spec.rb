require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaigns/index.html.erb" do
  include FreemailerCampaignsHelper
  
  before(:each) do
    assigns[:freemailer_campaigns] = [
      stub_model(FreemailerCampaign,
        :subject => "value for subject",
        :title => "value for title",
        :body_template => "value for body_template",
        :sender_id => 1
      ),
      stub_model(FreemailerCampaign,
        :subject => "value for subject",
        :title => "value for title",
        :body_template => "value for body_template",
        :sender_id => 1
      )
    ]
  end

  it "renders a list of freemailer_campaigns" do
    render
    response.should have_tag("tr>td", "value for subject".to_s, 2)
    response.should have_tag("tr>td", "value for title".to_s, 2)
    response.should have_tag("tr>td", "value for body_template".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end

