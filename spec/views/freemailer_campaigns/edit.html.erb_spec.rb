require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaigns/edit.html.erb" do
  include FreemailerCampaignsHelper
  
  before(:each) do
    assigns[:freemailer_campaign] = @freemailer_campaign = stub_model(FreemailerCampaign,
      :new_record? => false,
      :subject => "value for subject",
      :title => "value for title",
      :body_template => "value for body_template",
      :sender_id => 1
    )
  end

  it "renders the edit freemailer_campaign form" do
    render
    
    response.should have_tag("form[action=#{freemailer_campaign_path(@freemailer_campaign)}][method=post]") do
      with_tag('textarea#freemailer_campaign_subject[name=?]', "freemailer_campaign[subject]")
      with_tag('input#freemailer_campaign_title[name=?]', "freemailer_campaign[title]")
      with_tag('textarea#freemailer_campaign_body_template[name=?]', "freemailer_campaign[body_template]")
      with_tag('input#freemailer_campaign_sender_id[name=?]', "freemailer_campaign[sender_id]")
    end
  end
end


