class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.references :user, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :name, :string, :limit => 300, :null => false
      t.column :search, :string, :limit => 2000, :null => false
      t.column :category, :string, :limit => 100, :null => false, :default => 'Uncategorized'
      t.timestamps
    end
    %W|name category|.each do|column|
      add_index :saved_searches, column
    end
  end

  def self.down
    drop_table :saved_searches
  end
end
