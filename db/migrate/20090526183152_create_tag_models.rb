class CreateTagModels < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|

      # Needed by acts_as_category
      t.integer :parent_id, :position, :children_count, :ancestors_count, :descendants_count
      t.boolean :hidden
      # End acts_as_category columns

      t.string :title
      t.string :description
      t.boolean :removable, :default => true

      t.timestamps
    end
    
    create_table :taggings do |t|
      t.references :freetaggable, :polymorphic => true, :references => nil
      t.references :tag
      t.column :relationship, :string, :limit => 100
      t.timestamps
    end
  end

  def self.down
    drop_table :tags
    drop_table :taggings
  end
end
