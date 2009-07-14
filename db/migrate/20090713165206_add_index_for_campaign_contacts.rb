class AddIndexForCampaignContacts < ActiveRecord::Migration
  def self.up
    add_index :freemailer_campaign_contacts, [:contact_id, :freemailer_campaign_id], :unique => true
  end

  def self.down
    remove_index :freemailer_campaign_contacts, :column => [:contact_id, :freemailer_campaign_id]
  end
end
