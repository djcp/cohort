require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaign_contacts/index.html.erb" do
  include FreemailerCampaignContactsHelper
  
  before(:each) do
    assigns[:freemailer_campaign_contacts] = [
      stub_model(FreemailerCampaignContact,
        :freemailer_campaign_id => 1,
        :contact_id => 1,
        :delivery_status => "value for delivery_status"
      ),
      stub_model(FreemailerCampaignContact,
        :freemailer_campaign_id => 1,
        :contact_id => 1,
        :delivery_status => "value for delivery_status"
      )
    ]
  end

  it "renders a list of freemailer_campaign_contacts" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for delivery_status".to_s, 2)
  end
end

