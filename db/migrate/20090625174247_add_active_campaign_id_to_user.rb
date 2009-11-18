class AddActiveCampaignIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active_campaign_id, :integer, :default => nil, :references => :freemailer_campaigns
  end

  def self.down
    remove_column :users, :active_campaign_id
  end
end
