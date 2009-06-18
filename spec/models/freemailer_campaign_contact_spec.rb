require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaignContact do
  before(:each) do
    @valid_attributes = {
      :freemailer_campaign_id => Factory(:freemailer_campaign).id,
      :contact_id => Factory(:contact).id,
      :delivery_status => "value for delivery_status"
    }
  end

  it "should create a new instance given valid attributes" do
    FreemailerCampaignContact.create!(@valid_attributes)
  end

  it { should belong_to :freemailer_campaign }
  it { should belong_to :contact }

  it { should have_db_column :delivery_status }
end
