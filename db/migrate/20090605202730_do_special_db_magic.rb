class DoSpecialDbMagic < ActiveRecord::Migration
  def self.up
    %W|title position parent_id removable|.each do|column|
      add_index :tags, column
    end

    migration_helper_class = CohortMigrationHelper.init_helper_class(self.connection)
    if migration_helper_class
      migration_helper_class.after_tag_table_create.each do |extension_statement|
        execute extension_statement
      end
    end
    
    # create_table :taggings do |t|
    #   t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
    #   t.references :tag, :null => false, :on_update => :cascade, :on_delete => :cascade
    # 
    #   t.timestamps
    # end

    add_index :taggings, ['freetaggable_id','freetaggable_type', 'tag_id'], :unique => true
    %W|freetaggable_id freetaggable_type tag_id created_at updated_at|.each do |column|
      add_index :taggings, column
    end
    special = Tag.create(:title => 'Special', :removable => false)
    autotags = Tag.create(:title => 'Autotags', :removable => false, :parent => special)
    never_email = Tag.create(:title => 'Never Email', :removable => false, :parent => special)
    never_contact = Tag.create(:title => 'Never Contact', :removable => false, :parent => special)
    never_phone = Tag.create(:title => 'Never Phone', :removable => false, :parent => special)
    uncategorized = Tag.create(:title => 'Uncategorized', :removable => false)
  end

  def self.down
    migration_helper_class = CohortMigrationHelper.init_helper_class(self.connection)
    if migration_helper_class
      migration_helper_class.before_tag_table_destroy.each do |extension_statement|
        execute extension_statement
      end
    end
  end
end
