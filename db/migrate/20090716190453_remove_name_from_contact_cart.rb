class RemoveNameFromContactCart < ActiveRecord::Migration
  def self.up
      remove_column :contact_carts, :name
      add_column :contact_carts, :title, :string
  end

  def self.down
  end
end
