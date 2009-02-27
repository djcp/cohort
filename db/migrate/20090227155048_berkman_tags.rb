class BerkmanTags < ActiveRecord::Migration
  def self.up
    ab = Tag.create(:tag => 'All Berkman', :immutable => true)
    ['Staff','Fellows','Affiliates','Faculty','Alumni','Friends'].each do |tag|
      Tag.create(:tag => tag, :parent => ab, :immutable => true)
    end
    ab.move_higher
    ab.save
  end

  def self.down
  end
end
