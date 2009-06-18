require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FreemailerCampaign do
  before(:each) do
    @valid_attributes = {
      :subject => "value for subject",
      :title => "value for title",
      :body_template => "value for body_template",
      :sender_id => Factory(:user).id
    }
  end

  it "should create a new instance given valid attributes" do
    FreemailerCampaign.create!(@valid_attributes)
  end

  it { should have_many :freemailer_campaign_contacts }
  it { should have_many :contacts }
  it { should belong_to :sender }

  it { should have_db_column :subject }
  it { should have_db_column :title }
  it { should have_db_column :body_template }

end
