# A FreemailerCampaign is an encapsulation of a mail campaign that is to be sent, and the Contacts that it is being sent to
class FreemailerCampaign < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_many :freemailer_campaign_contacts, :dependent => :destroy
  has_many :contacts, :through => :freemailer_campaign_contacts

  validates_uniqueness_of :title, :scope => :sender_id, :on => :create, :message => "must be unique" #JS me

  before_destroy :remove_active_campaign

  # Joins all contact names into a one line string
  #
  # E.g. With the contacts <tt>"Burt Reynolds"</tt>, <tt>"Sean Connery"</tt> and <tt>"Alec Trebek"</tt> the output will be <tt>"Burt Reynolds, Sean Connery, Alec Trebek"</tt>
  def contact_names
    contacts.map(&:name_for_display).join(', ').squeeze(' ')
  end

  # A mapping of Contacts to their <tt>#primary_email</tt>
  def contact_emails
    self[:contacts].map(&:primary_email)
  end

  # Textual status of the campaign. One of <tt>['Sent', 'Unsent']</tt>
  def status
    if sent
      'Sent'
    else
      'Unsent'
    end
  end

  # Set the sender's +active_campaign+ to +self+
  def make_active_for_sender
    sender.active_campaign = self
    sender.save
  end

  # Fill in +template+ with a preview user
  #
  #   "Hello [[first name]]. How is the [[last name]] family." 
  #
  # becomes...
  #
  #   "Hello John. How is the Doe family."
  def preview
    fill_template(preview_user)
  end

  # Register with +delayed_job+ that each contact should be sent an individual mail.
  #
  # Note: This service _must_ be run via <tt>rake jobs:work</tt> for mail to be sent
  def send_campaign
    if not self[:sent]
      freemailer_campaign_contacts.each do |contact_join|
        self.send_later(:send_individual_mail,contact_join)
      end
      self[:sent] = true; self.save
    end
  end

  # Send a mail to an individual contact.
  #
  # If the current delivery status does not match success then try sending the mail again.
  # 
  # If this raises an error catch the error and set it as the delivery status.
  def send_individual_mail(contact_join)
    begin
      if contact_join.delivery_status !~ /Success/
        Freemailer.deliver_from_template(self,contact_join.contact)
        contact_join.delivery_status = "Successful"
        contact_join.save
      end
    rescue Net::SMTPError => e
      puts "Delivery error rescued!"
      debugger
      contact_join.delivery_status = e.to_s
      contact_join.save
    end
  end
  
  # A hash for a fake user. Used for preview merges.
  def preview_user
    {
      'first name' => 'John',
      'last name' => 'Doe',
      'middle name' => 'H',
      'name' => 'John Doe',
      'email' => 'john@doe.com',
      'address' => "123 Some Pl.\nWhere, Ever  90210\nCanada"
    }
  end

  # Initiate the filling of the campaign template with details from a given person.
  def fill_template_for_contact(person)
    fill_template ({
      'first name' => person.first_name,
      'last name' => person.last_name,
      'middle name' => person.middle_name,
      'middle initial' => (person.middle_name or '').first.upcase,
      'name' => person.name_for_display,
      'email' => person.primary_email,
      'address' => person.primary_address
    })
  end

  # Perform the actual replacement of tags with relevent user values
  def fill_template(user_hash)
    user_hash.default = ''
    (body_template ||  " -- Body is empty -- ").gsub(/\[\[(.*?)\]\]/) do |item|
      user_hash[$1].to_s
    end
  end
  
  # Count the number of contacts who have been succesfully contacted
  def successfully_sent
    freemailer_campaign_contacts.count( :conditions => { :delivery_status => "Successful" })
  end

  # Remove campaign as the active campaign for the sender
  def remove_active_campaign
    if sender.active_campaign == self
      sender.active_campaign = nil
      sender.save
    end
  end
end
