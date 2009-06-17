class CreateFreemailerCampaigns < ActiveRecord::Migration
  def self.up
    create_table :freemailer_campaigns do |t|
      t.text :subject
      t.string :title
      t.text :body_template
      t.integer :sender_id

      t.timestamps
    end
  end

  def self.down
    drop_table :freemailer_campaigns
  end
end
