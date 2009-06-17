require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaignContact do
  before(:each) do
    @valid_attributes = {
      :freemailer_campaign_id => 1,
      :contact_id => 1,
      :delivery_status => "value for delivery_status"
    }
  end

  it "should create a new instance given valid attributes" do
    FreemailerCampaignContact.create!(@valid_attributes)
  end
end
