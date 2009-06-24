class AddSentToFreemailerCampaign < ActiveRecord::Migration
  def self.up
    add_column :freemailer_campaigns, :sent, :boolean, :default => false
  end

  def self.down
    remove_column :freemailer_campaigns, :sent
  end
end
