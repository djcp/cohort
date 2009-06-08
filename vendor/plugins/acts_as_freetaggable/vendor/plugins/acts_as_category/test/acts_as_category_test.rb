# Test for acts_as_category
#
# There are several ways to execute this test:
#
# 1. Open this file on a Mac in TextMate and press APPLE + R
# 2. Go to "vendor/plugins/acts_as_category/test" and run "rake test" in a terminal window
# 3. Run "rake test:plugins" in a terminal window to execute tests of all plugins
#
# For further information see http://blog.funkensturm.de/downloads

require 'test/unit'

require 'rubygems'
require 'active_record'
require 'action_view'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
$stdout = StringIO.new # Prevent ActiveRecord's annoying schema statements

def setup_db
  ActiveRecord::Base.logger
  ActiveRecord::Schema.define(:version => 1) do
    create_table "categories", :force => true do |t|
      t.integer "my_parent_id"
      t.integer "my_position"
      t.boolean "my_hidden"
      t.integer "my_children_count"
      t.integer "my_ancestors_count"
      t.integer "my_descendants_count"
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

setup_db # Because the plugin needs an existing table before initialization (e.g. for attr_readonly)

$:.unshift File.dirname(__FILE__) + '/../lib' # make "lib" known to "require"
require 'active_record/acts/category'
require 'active_record/acts/category_content'
require 'acts_as_category_helper'
require File.dirname(__FILE__) + '/../init' # Initialize Plugin

class Category < ActiveRecord::Base
  acts_as_category :foreign_key => 'my_parent_id',
                   :position => 'my_position',
                   :hidden => 'my_hidden',
                   :children_count => 'my_children_count',
                   :ancestors_count => 'my_ancestors_count',
                   :descendants_count => 'my_descendants_count'
end

teardown_db # Because CategoryTest's setup method won't execute setup_db otherwise

class CategoryTest < Test::Unit::TestCase
  
  # Test category trees:
  #
  #   r1                 r2                 r3
  #    \_ r11             \_ r21
  #         \_ r111       \    \_ r211
  #                       \_ r22
  #                            \_ r221
  def setup
    setup_db
    assert @r1   = Category.create! # id 1
    assert @r2   = Category.create! # id 2
    assert @r3   = Category.create! # id 3
    assert @r11  = Category.create!(:my_parent_id => @r1.id) # id 4
    assert @r21  = Category.create!(:my_parent_id => @r2.id) # id 5
    assert @r22  = Category.create!(:my_parent_id => @r2.id) # id 6
    assert @r111 = Category.create!(:my_parent_id => @r11.id) # id 7
    assert @r211 = Category.create!(:my_parent_id => @r21.id) # id 8
    assert @r221 = Category.create!(:my_parent_id => @r22.id) # id 9
    assert @r1   = Category.find(1)
    assert @r2   = Category.find(2)
    assert @r3   = Category.find(3)
    assert @r11  = Category.find(4)
    assert @r21  = Category.find(5)
    assert @r22  = Category.find(6)
    assert @r111 = Category.find(7)
    assert @r211 = Category.find(8)
    assert @r221 = Category.find(9)
    Category.permissions.clear
  end

  def teardown
    teardown_db
  end
  
  def check_cache # This is merely a method used by certain tests
    Category.find(:all).each { |c|
      # Note that "children_count" is a built-in Rails functionality and must not be tested here
      assert_equal c.ancestors.size,   c.my_ancestors_count
      assert_equal c.descendants.size, c.my_descendants_count
    }
  end
  
  def test_cache_columns
    check_cache
  end
  
  def test_permissions_class_variable
    Category.permissions = nil
    assert_equal [], Category.permissions
    Category.permissions = [nil]
    assert_equal [], Category.permissions
    Category.permissions = [0]
    assert_equal [], Category.permissions
    Category.permissions = 'string'
    assert_equal [], Category.permissions
    Category.permissions = [1]
    assert_equal [1], Category.permissions
    Category.permissions = [1,2,3]
    assert_equal [1,2,3], Category.permissions
    Category.permissions = [1,'string',3]
    assert_equal [1,3], Category.permissions
    Category.permissions.clear
    assert_equal [], Category.permissions
  end

  def test_where_permitted_sql_query
    assert_equal ' (my_hidden IS NULL) ', Category.where_permitted
    assert_equal ' AND (my_hidden IS NULL) ', Category.where_permitted(true)
    Category.permissions = [1,2,3]
    assert_equal ' (my_hidden IS NULL OR id IN (1,2,3)) ', Category.where_permitted
    assert_equal ' AND (my_hidden IS NULL OR id IN (1,2,3)) ', Category.where_permitted(true)
  end
  
  def test_attr_readonly
    assert @r1.my_children_count = 99
    assert @r1.my_ancestors_count = 99
    assert @r1.my_descendants_count = 99
    assert @r1.save
    assert @r1 = Category.find(1)
    assert_equal 1, @r1.my_children_count
    # See http://github.com/funkensturm/acts_as_category/commit/e00904a06fd27e013424c55c105342aff20fc375
    #assert_equal 0, @r1.my_ancestors_count
    #assert_equal 2, @r1.my_descendants_count
    assert @r1.update_attribute('my_children_count', 99)
    assert @r1.update_attribute('my_ancestors_count', 99)
    assert @r1.update_attribute('my_descendants_count', 99)
    assert @r1 = Category.find(1)
    assert_equal 1, @r1.my_children_count
    #assert_equal 0, @r1.my_ancestors_count
    #assert_equal 2, @r1.my_descendants_count
  end

  def test_permitted?
    assert @r3.permitted?
    assert @r3.update_attribute('my_hidden', true)
    assert !@r3.permitted?
    Category.permissions = [@r3.id]
    assert @r3.permitted?
    Category.permissions.clear
    assert !@r3.permitted?
    assert @r3.update_attribute('my_hidden', false)
    assert @r3.permitted?
    assert @r2.permitted?
    assert @r21.permitted?
    assert @r211.permitted?
    assert @r211.update_attribute('my_hidden', true)
    assert @r2.permitted?
    assert @r21.permitted?
    assert !@r211.permitted?
    Category.permissions = [@r211.id]
    assert @r2.permitted?
    assert @r21.permitted?
    assert @r211.permitted?
    Category.permissions.clear
    Category.permissions = [99]
    assert @r2.permitted?
    assert @r21.permitted?
    assert !@r211.permitted?
    assert @r211.update_attribute('my_hidden', false)
    assert @r2.permitted?
    assert @r21.permitted?
    assert @r211.permitted?
    assert @r21.update_attribute('my_hidden', true)
    assert @r2.permitted?
    assert !@r21.permitted?
    assert !@r211.my_hidden
    assert !@r211.permitted?
    Category.permissions = [@r21.id]
    assert @r2.permitted?
    assert @r21.permitted?
    assert @r211.permitted?
    Category.permissions.clear
    assert @r2.update_attribute('my_hidden', true)
    assert @r21.update_attribute('my_hidden', false)
    assert !@r2.permitted?
    assert !@r21.permitted?
    assert !@r211.permitted?
    Category.permissions = [@r21.id, @r211.id]
    assert !@r2.permitted?
    assert !@r21.permitted?
    assert !@r211.permitted?
    Category.permissions = [@r2.id]
    assert @r2.permitted?
    assert @r21.permitted?
    assert @r211.permitted?
  end

  def test_children
    assert_equal [@r11], @r1.children
    assert_equal [@r21, @r22], @r2.children
    assert_equal [], @r3.children
    assert_equal [@r111], @r11.children
    assert_equal [], @r111.children
    assert_equal [@r211], @r21.children
    assert_equal [@r221], @r22.children
    assert_equal [], @r211.children
    assert_equal [], @r221.children
  end

  def test_children_permissions
    assert @r22.update_attribute('my_hidden', true)
    assert_equal [@r21, @r22], @r2.orig_children
    assert_equal [@r11], @r1.children
    assert_equal [@r21], @r2.children
    assert_equal [], @r3.children
    assert_equal [@r111], @r11.children
    assert_equal [], @r111.children
    assert_equal [@r211], @r21.children
    assert_equal [], @r22.children
    assert_equal [], @r211.children
    assert_equal [], @r221.children
  end
  
  def test_children_ids
    assert_equal [4], @r1.children_ids
    assert_equal [5, 6], @r2.children_ids
    assert_equal [], @r3.children_ids
    assert_equal [7], @r11.children_ids
    assert_equal [], @r111.children_ids
    assert_equal [8], @r21.children_ids
    assert_equal [9], @r22.children_ids
    assert_equal [], @r211.children_ids
    assert_equal [], @r221.children_ids
  end

  def test_children_ids_permissions
    assert @r22.update_attribute('my_hidden', true)
    assert_equal [4], @r1.children_ids
    assert_equal [5], @r2.children_ids
    assert_equal [], @r3.children_ids
    assert_equal [7], @r11.children_ids
    assert_equal [], @r111.children_ids
    assert_equal [8], @r21.children_ids
    assert_equal [], @r22.children_ids
    assert_equal [], @r211.children_ids
    assert_equal [], @r221.children_ids
  end

   def test_children_size
     assert_equal 1, @r1.children.size
     assert_equal 2, @r2.children.size
     assert_equal 0, @r3.children.size
     assert_equal 1, @r11.children.size
     assert_equal 0, @r111.children.size
     assert_equal 1, @r21.children.size
     assert_equal 1, @r22.children.size
     assert_equal 0, @r211.children.size
     assert_equal 0, @r221.children.size
     assert @r111.update_attribute('my_hidden', true)
     assert @r22.update_attribute('my_hidden', true)
     assert_equal 1, @r1.children.size
     assert_equal 1, @r2.children.size
     assert_equal 0, @r3.children.size
     assert_equal 0, @r11.children.size
     assert_equal 0, @r111.children.size
     assert_equal 1, @r21.children.size
     assert_equal 0, @r22.children.size
     assert_equal 0, @r211.children.size
     assert_equal 0, @r221.children.size
  end

  def test_parent
    assert_nil @r1.parent
    assert_nil @r2.parent
    assert_nil @r3.parent
    assert_equal @r1, @r11.parent
    assert_equal @r11, @r111.parent
    assert_equal @r2, @r21.parent
    assert_equal @r2, @r22.parent
    assert_equal @r21, @r211.parent
    assert_equal @r22, @r221.parent
  end

  def test_ancestors
    assert_equal [], @r1.ancestors
    assert_equal [], @r2.ancestors
    assert_equal [], @r3.ancestors
    assert_equal [@r1], @r11.ancestors
    assert_equal [@r2], @r21.ancestors
    assert_equal [@r2], @r22.ancestors
    assert_equal [@r11, @r1], @r111.ancestors
    assert_equal [@r21, @r2], @r211.ancestors
    assert_equal [@r22, @r2], @r221.ancestors
  end

  def test_ancestors_ids
    assert_equal [], @r1.ancestors_ids
    assert_equal [], @r2.ancestors_ids
    assert_equal [], @r3.ancestors_ids
    assert_equal [1], @r11.ancestors_ids
    assert_equal [2], @r21.ancestors_ids
    assert_equal [2], @r22.ancestors_ids
    assert_equal [4, 1], @r111.ancestors_ids
    assert_equal [5, 2], @r211.ancestors_ids
    assert_equal [6, 2], @r221.ancestors_ids
  end

  def test_descendants
    assert_equal [@r11, @r111], @r1.descendants
    assert_equal [@r21, @r211, @r22, @r221], @r2.descendants
    assert_equal [], @r3.descendants
    assert_equal [@r111], @r11.descendants
    assert_equal [@r211], @r21.descendants
    assert_equal [@r221], @r22.descendants
    assert_equal [], @r111.descendants
    assert_equal [], @r211.descendants
    assert_equal [], @r221.descendants
  end
  
  def test_descendants_permissions
    assert @r22.update_attribute('my_hidden', true)
    assert_equal [@r11, @r111], @r1.descendants
    assert_equal [@r21, @r211], @r2.descendants
    assert_equal [], @r3.descendants
    assert_equal [@r111], @r11.descendants
    assert_equal [], @r111.descendants
    assert_equal [@r211], @r21.descendants
    assert_equal [], @r22.descendants
    assert_equal [], @r211.descendants
    assert_equal [], @r221.descendants
  end
  
  def test_descendants_ids
    assert_equal [4, 7], @r1.descendants_ids
    assert_equal [5, 8, 6, 9], @r2.descendants_ids
    assert_equal [], @r3.descendants_ids
    assert_equal [7], @r11.descendants_ids
    assert_equal [8], @r21.descendants_ids
    assert_equal [9], @r22.descendants_ids
    assert_equal [9], @r22.descendants_ids
    assert_equal [9], @r22.descendants_ids
    assert_equal [], @r111.descendants_ids
    assert_equal [], @r211.descendants_ids
    assert_equal [], @r221.descendants_ids
    assert_equal [], @r221.descendants_ids
  end

  def test_descendants_ids_permissions
    assert @r22.update_attribute('my_hidden', true)
    assert_equal [4, 7], @r1.descendants_ids
    assert_equal [5, 8], @r2.descendants_ids
    assert_equal [], @r3.descendants_ids
    assert_equal [7], @r11.descendants_ids
    assert_equal [], @r111.descendants_ids
    assert_equal [8], @r21.descendants_ids
    assert_equal [], @r22.descendants_ids
    assert_equal [], @r211.descendants_ids
    assert_equal [], @r221.descendants_ids
  end
  
  def test_root
    assert_equal @r1, @r1.root
    assert_equal @r1, @r11.root
    assert_equal @r1, @r111.root
    assert_equal @r2, @r21.root
    assert_equal @r2, @r211.root
    assert_equal @r2, @r22.root
    assert_equal @r2, @r221.root
    assert_equal @r3, @r3.root
  end

  def test_root_permissions # i. e. ignoring permissions
    assert @r22.update_attribute('my_hidden', true)
    assert_equal @r2, @r2.root
    assert_equal @r2, @r22.root
    assert_equal @r2, @r221.root
  end
  
  def test_root?
    assert @r1.root?
    assert @r3.root?
    assert !@r11.root?
  end
  
  def test_root_permissions # i. e. ignoring permissions
    assert @r3.update_attribute('my_hidden', true)
    assert @r1.root?
    assert @r3.root?
    assert !@r11.root?
  end
  
  def test_roots
    assert_equal [@r1, @r2, @r3], Category.roots
    assert_equal [@r1, @r2, @r3], Category.roots(true)
  end

  def test_roots_permissions
    assert @r2.update_attribute('my_hidden', true)
    assert_equal [@r1, @r3], Category.roots
  end
  
  def test_roots_permissions_override
    assert @r2.update_attribute('my_hidden', true)
    assert_equal [@r1, @r2, @r3], Category.roots(true)
  end
  
  def test_siblings
    assert_equal [@r2, @r3], @r1.siblings
    assert_equal [@r1, @r3], @r2.siblings
    assert_equal [@r1, @r2], @r3.siblings
    assert_equal [], @r11.siblings
    assert_equal [@r22], @r21.siblings
    assert_equal [@r21], @r22.siblings
    assert_equal [], @r111.siblings
    assert_equal [], @r211.siblings
    assert_equal [], @r221.siblings
  end
  
  def test_siblings_permissions
    assert @r2.update_attribute('my_hidden', true)
    assert_equal [@r3], @r1.siblings
    assert_equal [@r1, @r3], @r2.siblings
    assert_equal [@r1], @r3.siblings
    assert_equal [], @r11.siblings
    assert_equal [], @r21.siblings
    assert_equal [], @r22.siblings
    assert_equal [], @r111.siblings
    assert_equal [], @r211.siblings
    assert_equal [], @r221.siblings
    assert @r22.update_attribute('my_hidden', true)
    assert_equal [], @r21.siblings
    assert_equal [], @r22.siblings
    assert_equal [], @r111.siblings
    assert_equal [], @r211.siblings
    assert_equal [], @r221.siblings
    assert @r2.update_attribute('my_hidden', false)
    assert_equal [], @r22.siblings
  end
  
  def test_self_and_siblings
    assert_equal [@r1, @r2, @r3], @r1.self_and_siblings
    assert_equal [@r1, @r2, @r3], @r2.self_and_siblings
    assert_equal [@r1, @r2, @r3], @r3.self_and_siblings
    assert_equal [@r11], @r11.self_and_siblings
    assert_equal [@r21, @r22], @r21.self_and_siblings
    assert_equal [@r21, @r22], @r22.self_and_siblings
    assert_equal [@r111], @r111.self_and_siblings
    assert_equal [@r211], @r211.self_and_siblings
    assert_equal [@r221], @r221.self_and_siblings
  end

  def test_self_and_siblings_permissions
    assert @r22.update_attribute('my_hidden', true)
    assert_equal [@r1, @r2, @r3], @r1.self_and_siblings
    assert_equal [@r1, @r2, @r3], @r2.self_and_siblings
    assert_equal [@r1, @r2, @r3], @r3.self_and_siblings
    assert_equal [@r11], @r11.self_and_siblings
    assert_equal [@r21], @r21.self_and_siblings
    assert_equal [@r21], @r22.self_and_siblings
    assert_equal [@r111], @r111.self_and_siblings
    assert_equal [@r211], @r211.self_and_siblings
    assert_equal [], @r221.self_and_siblings
  end
  
  def test_dependent_destroy_and_cache
    assert_equal 9, Category.count
    assert @r1.destroy
    assert_equal 6, Category.count
    check_cache
    assert @r211.destroy
    assert_equal 5, Category.count
    check_cache
    assert @r21.destroy
    assert_equal 4, Category.count
    check_cache
    assert @r22.destroy
    assert_equal 2, Category.count
    check_cache
    assert @r2.destroy
    assert @r3.destroy
    assert_equal 0, Category.count
    check_cache
  end

  def test_insert_and_cache
    teardown_db
    setup_db
    assert @r1   = Category.create!
    check_cache
    assert @r2   = Category.create!
    check_cache
    Category.new().save
    assert @r3 = Category.find(3)
    check_cache
    assert @r11  = Category.create!(:my_parent_id => @r1.id)
    check_cache
    Category.new(:my_parent_id => @r2.id).save
    assert @r21 = Category.find(5)
    check_cache
    assert @r22  = Category.create!(:my_parent_id => @r2.id)
    check_cache
    Category.new(:my_parent_id => @r11.id).save
    assert @r111 = Category.find(7)
    check_cache
    assert @r211 = Category.create!(:my_parent_id => @r21.id)
    check_cache
    assert @r221 = Category.create!(:my_parent_id => @r22.id)
    check_cache
    @r12 = @r1.children.create
    check_cache
    assert @r12
    assert_equal @r12.parent, @r1
    assert @r1 = Category.find(1)
    assert_equal 2, @r1.children.size
    assert @r1.children.include?(@r12)
    assert @r1.children.include?(@r11)
    check_cache
  end

  def test_update_where_root_becomes_child
    @r1.update_attributes(:my_parent_id => @r21.id)
    check_cache
  end

  def test_update_where_child_becomes_root
    @r111.update_attributes(:my_parent_id =>nil)
    check_cache
  end

  def test_update_where_child_switches_within_branch
    @r22.update_attributes(:my_parent_id => @r211.id)
    check_cache
  end

  def test_update_where_child_switches_branch
    @r221.update_attributes(:my_parent_id => @r11.id)
    check_cache
  end

  def test_invalid_parent_id_type
    assert !Category.new(:my_parent_id => 0.0).save
    assert !Category.new(:my_parent_id => 1.5).save
    assert !Category.new(:my_parent_id => 0).save
    assert !Category.new(:my_parent_id => 'string').save
  end

  def test_non_existant_foreign_key
    assert !Category.new(:my_parent_id => 9876543210).save
    assert_raise(ActiveRecord::RecordInvalid) { Category.create!(:my_parent_id => 9876543210) }
  end

  def test_category_becomes_its_own_parent
    assert !@r1.update_attributes(:my_parent_id => @r1.id)
    assert @r2.my_parent_id = @r2.id
    assert !@r2.save
  end

  def test_category_becomes_parent_of_descendant
    assert !@r1.update_attributes(:my_parent_id => @r11.id)
    assert !@r1.update_attributes(:my_parent_id => @r111.id)
    assert !@r11.update_attributes(:my_parent_id => @r111.id)
    assert @r2.my_parent_id = @r21.id
    assert !@r2.save
  end

  def test_update_positions
    Category.update_positions({'aac_sortable_tree_0' => [3,1,2]})
    assert_equal 1, Category.find(3).my_position
    assert_equal 2, Category.find(1).my_position
    assert_equal 3, Category.find(2).my_position
    Category.update_positions({'aac_sortable_tree_2' => [6,5]})
    assert_equal 1, Category.find(6).my_position
    assert_equal 2, Category.find(5).my_position
    assert_raise(::ArgumentError) { Category.update_positions({'aac_sortable_tree_2' => [1]}) }
    assert_raise(::ArgumentError) { Category.update_positions({'aac_sortable_tree_2' => [1,2,3]}) }
    assert_raise(::ArgumentError) { Category.update_positions({'aac_sortable_tree_2' => [5,6,7]}) }
    assert_raise(::ArgumentError) { Category.update_positions({'aac_sortable_tree_9876543210' => [1]}) }
    assert_raise(::ArgumentError) { Category.update_positions({'aac_sortable_tree_1' => [9876543210]}) }
  end

  def get
    assert_equal @r1, Category.get(1)
    assert @r1.update_attribute('my_hidden', true)
    assert_nil Category.get(1)
    assert_nil Category.get(4)
    assert_nil Category.get(7)
    assert_equal @r2, Category.get(2)
    assert_equal @r3, Category.get(3)
  end
  
end
