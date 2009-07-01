class Freemailer < ActionMailer::Base
  

  def from_template(campaign, contact, sent_at = Time.now)
    subject    campaign.subject
    recipients contact.primary_email
    from       campaign.from
    sent_on    sent_at

    body       campaign.fill_template_for_contact(contact)
  end

end
