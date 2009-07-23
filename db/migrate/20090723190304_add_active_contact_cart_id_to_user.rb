class AddActiveContactCartIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active_contact_cart_id, :integer, :references => :contact_carts
  end

  def self.down
    remove_column :users, :active_contact_cart_id
  end
end
