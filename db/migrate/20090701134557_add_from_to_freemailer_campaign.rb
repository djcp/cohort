class AddFromToFreemailerCampaign < ActiveRecord::Migration
  def self.up
    add_column :freemailer_campaigns, :from, :string
  end

  def self.down
    remove_column :freemailer_campaigns, :from
  end
end
