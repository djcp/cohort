class CreateFreemailerCampaigns < ActiveRecord::Migration
  def self.up
    create_table :freemailer_campaigns do |t|
      t.string :subject
      t.string :title
      t.text :body_template
      t.integer :sender_id, :references => :users
      t.boolean :sent, :default => false
      t.string :from
      
      t.timestamps
    end
  end

  def self.down
    drop_table :freemailer_campaigns
  end
end
