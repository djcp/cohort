class CreateLogItems < ActiveRecord::Migration
  def self.up
    create_table :log_items do |t|
      t.references :user, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :item_id, :integer, :references => nil, :null => false
      t.column :item_type, :string, :limit => 500, :null => false
      t.column :message, :string, :limit => 1000, :null => false
      t.column :kind, :string, :limit => 50, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :log_items
  end
end
