class Tag < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_list :scope => :parent_id
  acts_as_tree :order => :position
  has_and_belongs_to_many :contacts
  
  def self.select_options
    tree = Tag.find(:all, :include => [ :children ], :order => :position)
    options = [['-- root tag--',nil]]
    self.recurse_for_select_options(tree,nil,0,options)
    return options
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
