class FreemailerCampaign < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_many :freemailer_campaign_contacts, :dependent => :destroy
  has_many :contacts, :through => :freemailer_campaign_contacts

  validates_uniqueness_of :title, :scope => :sender_id, :on => :create, :message => "must be unique" #JS me

  before_destroy :remove_active_campaign

  def contact_names
    contacts.map(&:name_for_display).join(', ').squeeze(' ')
  end

  def status
    if sent
      'Sent'
    else
      'Unsent'
    end
  end

  def make_active_for_sender
    sender.active_campaign = self
    sender.save
  end

  def preview
    
  end
  
  private

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

  def fill_template(user_hash)
    user_hash.default = ''
    body_template.gsub /\{(.*)\}/, user_hash[$1].to_s
  end

  def remove_active_campaign
    debugger
    if sender.active_campaign == self
      sender.active_campaign = nil
      sender.save
    end
  end
end
