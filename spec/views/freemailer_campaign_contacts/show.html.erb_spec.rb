require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaign_contacts/show.html.erb" do
  include FreemailerCampaignContactsHelper
  before(:each) do
    assigns[:freemailer_campaign_contact] = @freemailer_campaign_contact = stub_model(FreemailerCampaignContact,
      :freemailer_campaign_id => 1,
      :contact_id => 1,
      :delivery_status => "value for delivery_status"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ delivery_status/)
  end
end

