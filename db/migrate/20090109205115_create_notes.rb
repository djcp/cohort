class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.references :user, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.references :contact, :null => false, :on_update => :cascade, :on_delete => :cascade
      t.column :note, :string, :limit => 5000, :null => false
      t.column :position, :integer
      t.timestamps
    end
    %W|user_id contact_id position|.each do|column|
      add_index :notes, column
    end
  end

  def self.down
    drop_table :notes
  end
end
