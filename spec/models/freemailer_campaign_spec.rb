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

  it "should know its own status" do
    campaign = Factory.build(:freemailer_campaign,:sender_id => nil)
    campaign.sent = false
    campaign.status.should == 'Unsent'
    campaign.sent = true
    campaign.status.should == 'Sent'
  end

  it "should be able to concatenate its contacts into human readable format" do
    campaign = FreemailerCampaign.new
    campaign.stub!(:contacts).and_return do
      [ Contact.new( :first_name => 'that', :last_name => 'guy' ),
        Contact.new( :first_name => 'this', :last_name => 'guy' )]
    end
    campaign.contact_names.should == "that guy, this guy"
  end

  it { should respond_to :preview }
  it "should produce a preview with \"John Doe\" contact information merged in" do
    campaign = FreemailerCampaign.new( :body_template => 
                           "[[last name]]!\n" + 
                           "[[name]]\n" +
                           "[[address]]\n" )
    campaign.preview.should == <<-EOS
Doe!
John Doe
123 Some Pl.
Where, Ever  90210
Canada
    EOS
  end
end
