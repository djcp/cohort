require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaigns/show.html.erb" do
  include FreemailerCampaignsHelper
  before(:each) do
    assigns[:freemailer_campaign] = @freemailer_campaign = stub_model(FreemailerCampaign,
      :subject => "value for subject",
      :title => "value for title",
      :body_template => "value for body_template",
      :sender_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ subject/)
    response.should have_text(/value\ for\ title/)
    response.should have_text(/value\ for\ body_template/)
    response.should have_text(/1/)
  end
end

