require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/freemailer_campaign_contacts/edit.html.erb" do
  include FreemailerCampaignContactsHelper
  
  before(:each) do
    assigns[:freemailer_campaign_contact] = @freemailer_campaign_contact = stub_model(FreemailerCampaignContact,
      :new_record? => false,
      :freemailer_campaign_id => 1,
      :contact_id => 1,
      :delivery_status => "value for delivery_status"
    )
  end

  it "renders the edit freemailer_campaign_contact form" do
    render
    
    response.should have_tag("form[action=#{freemailer_campaign_contact_path(@freemailer_campaign_contact)}][method=post]") do
      with_tag('input#freemailer_campaign_contact_freemailer_campaign_id[name=?]', "freemailer_campaign_contact[freemailer_campaign_id]")
      with_tag('input#freemailer_campaign_contact_contact_id[name=?]', "freemailer_campaign_contact[contact_id]")
      with_tag('input#freemailer_campaign_contact_delivery_status[name=?]', "freemailer_campaign_contact[delivery_status]")
    end
  end
end


