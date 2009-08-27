# Freemailer is an ActionMailer class that is used to send Freemaielr Campaigns
class Freemailer < ActionMailer::Base
  # Send one email of a campaign to a specified contact. The template of the campaign is filled with the contact's information
  def from_template(campaign, contact, sent_at = Time.now)
    debugger
    subject    campaign.subject
    recipients contact.primary_email
    from       campaign.from
    sent_on    sent_at

    body       campaign.fill_template_for_contact(contact)
  end

end
