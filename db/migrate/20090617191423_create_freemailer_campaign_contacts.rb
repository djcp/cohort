class CreateFreemailerCampaignContacts < ActiveRecord::Migration
  def self.up
    create_table :freemailer_campaign_contacts do |t|
      t.integer :freemailer_campaign_id
      t.integer :contact_id
      t.string :delivery_status

      t.timestamps
    end
  end

  def self.down
    drop_table :freemailer_campaign_contacts
  end
end
