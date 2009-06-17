require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaign do
  before(:each) do
    @valid_attributes = {
      :subject => "value for subject",
      :title => "value for title",
      :body_template => "value for body_template",
      :sender_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    FreemailerCampaign.create!(@valid_attributes)
  end
end
