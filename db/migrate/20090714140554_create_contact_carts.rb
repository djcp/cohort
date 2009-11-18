class CreateContactCarts < ActiveRecord::Migration
  def self.up
    create_table :contact_carts do |t|
      t.integer :user_id
      t.string :title
      t.boolean :global, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_carts
  end
end
