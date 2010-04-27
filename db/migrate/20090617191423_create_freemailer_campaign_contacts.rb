class CreateFreemailerCampaignContacts < ActiveRecord::Migration
  def self.up
    create_table :freemailer_campaign_contacts do |t|
      t.integer :freemailer_campaign_id
      t.integer :contact_id
      t.string :delivery_status
 
      t.timestamps
    end
    add_index :freemailer_campaign_contacts, [:contact_id, :freemailer_campaign_id], :unique => true, :name => 'freemailer_name_index'
  end

  def self.down
    remove_index :freemailer_campaign_contacts, :column => [:contact_id, :freemailer_campaign_id]         
    drop_table :freemailer_campaign_contacts
  end
end
