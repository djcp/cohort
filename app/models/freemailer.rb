class Freemailer < ActionMailer::Base
  

  def from_template(sent_at = Time.now)
    subject    'Freemailer#from_template'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
