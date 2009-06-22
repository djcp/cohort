class FreemailerCampaign < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_many :freemailer_campaign_contacts, :dependent => :destroy
  has_many :contacts, :through => :freemailer_campaign_contacts
  
  validates_uniqueness_of :title, :on => :create, :message => "must be unique" #JS me
  
  def contact_names
    contacts.map(&:name_for_display).join(', ')
  end
end
