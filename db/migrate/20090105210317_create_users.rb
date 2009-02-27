class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string, :limit => 100, :null => false
      t.column :superadmin, :boolean, :default => false
      t.column :immutable, :boolean, :default => false
      t.timestamps
    end
    add_index :users, :username, :unique => true
    add_index :users, :superadmin
    add_index :users, :immutable
    User.create(:username => 'importer', :immutable => true)
  end

  def self.down
    drop_table :users
  end
end
