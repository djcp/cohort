class Tag < ActiveRecord::Base
  include CohortArMixin
  # Many validations are handled by the redhill schema_validations plugin.
  has_many :log_items, :as => :item, :dependent => :destroy
  acts_as_list :scope => :parent_id
  acts_as_tree :order => :position

  has_many :taggings
  has_many :contacts, :through => :taggings

  before_destroy :forbid_delete_of_immutable_objects

  def self.create_auto_tag(reason = 'Import')
    Tag.create(:tag => "Autotag: #{reason} - #{Time.now.to_s(:long)}", :parent => self.get_autotag_root_tag)
  end

  def self.get_special_root_tag
    self.find(:first, :conditions => ['tag = ? and parent_id is null','Special'])
  end

  def self.get_uncategorized_root_tag
    self.find(:first, :conditions => ['tag = ? and parent_id is null','Uncategorized'])
  end

  def self.get_autotag_root_tag
    self.find(:first, :conditions => ['tag = ? and parent_id =?','Autotags',self.get_special_root_tag.id])
  end

  def name_for_display
    self.hierarchical_title
  end

  def self.select_options
    tree = Tag.find(:all, :include => [ :children ], :order => :position)
    options = [['-- root tag--',nil]]
    self.recurse_for_select_options(tree,nil,0,options)
    return options
  end

  def hierarchical_title
    [self.my_parents.collect{|p| p.tag},self.tag].flatten.join(' -> ')
  end

  def my_parents
    parents = []
    recurse_for_parents(self,parents)
    parents && parents.reverse    
  end

  def get_all_children
    children = []
    recurse_for_children(self.children,children)
    return children
  end

  protected

  def recurse_for_children(tree,children)
    tree.each do|node|
        children << node 
        unless node.children.empty?        
          self.recurse_for_children(node.children,children) 
        end
    end
  end

  def recurse_for_parents(node,parents = [])
    unless node.parent == nil
      parents << node.parent
      recurse_for_parents(node.parent,parents)
    end
  end


  def self.recurse_for_select_options(tree,parent_id,depth,options)
    if parent_id == nil
      depth = 0
    else
      depth += 1
    end
    tree.each do|node|
      if node.parent_id == parent_id
        options << [('_' * (depth * 2)).to_s + node.tag, node.id]
          unless node.children.empty?        
            self.recurse_for_select_options(tree,node.id,depth,options) 
          end
      end
    end
  end

  def validate
    if self.parent_id != nil && (self.parent_id == self.id)
      errors.add('parent_id',"can't be moved to itself.")
    end
    # Need to validate that a node isn't trying to become a child of one of its children.
    unless self.parent_id == nil
      new_parent = Tag.find self.parent_id
      if self.get_all_children.include?(new_parent)
        errors.add('parent_id',"can't be moved there.")
      end
    end
  end
end
