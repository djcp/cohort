class CreateContactCartEntries < ActiveRecord::Migration
  def self.up
    create_table :contact_cart_entries do |t|
      t.integer :contact_cart_id
      t.integer :contact_id

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_cart_entries
  end
end
