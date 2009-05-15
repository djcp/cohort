require 'cohort_migration_helper'

class CreateTags < ActiveRecord::Migration
  def self.up
    # parent_id is treated as a selfsame reference by the redhill foreign key migrations plugin.
    create_table :tags do |t|
      t.column :parent_id, :integer
      t.column :tag, :string, :limit => 200, :null => false
      t.column :description, :string, :limit => 1000
      t.column :tag_path, :string, :limit => 5000
      t.column :position, :integer
      t.column :immutable, :boolean, :default => false
      t.timestamps
    end

    %W|tag position parent_id immutable|.each do|column|
      add_index :tags, column
    end

    migration_helper_class = CohortMigrationHelper.init_helper_class(self.connection)
    if migration_helper_class
      migration_helper_class.after_tag_table_create.each do |extension_statement|
        execute extension_statement
      end
    end
    
    create_table :taggings do |t|
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.references :tag, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :relationship, :string, :limit => 100
      t.timestamps
    end

    add_index :taggings, ['contact_id', 'tag_id'], :unique => true
    %W|contact_id tag_id created_at updated_at|.each do |column|
      add_index :taggings, column
    end
    special = Tag.create(:tag => 'Special', :immutable => true)
    autotags = Tag.create(:tag => 'Autotags', :immutable => true, :parent => special)
    never_email = Tag.create(:tag => 'Never Email', :immutable => true, :parent => special)
    never_contact = Tag.create(:tag => 'Never Contact', :immutable => true, :parent => special)
    never_phone = Tag.create(:tag => 'Never Phone', :immutable => true, :parent => special)
    uncategorized = Tag.create(:tag => 'Uncategorized', :immutable => true)
  end

  def self.down
    migration_helper_class = CohortMigrationHelper.init_helper_class(self.connection)
    if migration_helper_class
      migration_helper_class.before_tag_table_destroy.each do |extension_statement|
        execute extension_statement
      end
    end
    drop_table :taggings
    drop_table :tags
  end
end
