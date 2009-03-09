class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.references :user, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :name, :string, :limit => 300, :null => false
      t.column :search, :string, :limit => 2000, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :saved_searches
  end
end
