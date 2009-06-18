class FreemailerCampaign < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_many :freemailer_campaign_contacts
  has_many :contacts, :through => :freemailer_campaign_contacts
end
