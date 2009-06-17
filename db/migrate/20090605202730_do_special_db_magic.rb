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
