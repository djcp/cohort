class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.references :user, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :name, :string, :limit => 200, :null => false
      t.column :description, :string, :limit => 1000
      t.column :search_url, :string, :limit => 5000, :null => false
      t.column :category, :string, :limit => 100
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
