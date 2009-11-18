class FreemailerCampaignContact < ActiveRecord::Base
  belongs_to :freemailer_campaign
  belongs_to :contact
end
