class Tag < ActiveRecord::Base
  validates_presence_of :title
  validates_length_of :title, :maximum => 200
  validates_length_of :description, :maximum => 1000
  # Where things have gone/moved to
  # #validate no longer needed due to acts_as_category
  # before_destroy :forbid... is now before_destroy :removable?
  # #descendants replaces #get_all_children and #recurse_for_children
  # #ancestors replaces #my_parents and #recurse_for_parents

  acts_as_category

  # Polymorphic associations are added via this call.
  # This call will get wrapped in acts_as_freetaggable call when pluginized
  # has_many_polymorphs :freetaggables, :from => [:contacts], :through => :taggings
  # # has_many polymorphs DOES work with seperate listings
  # has_many_polymorphs :freetaggables, :from => [:comments], :through => :taggings

  before_destroy :removable?

  def removable?
    self.removable
  end

  def hierarchical_title #may also need #name_for_display
    (ancestors.map(&:title) << self.title).join(' -> ')
  end

  def move_up
    if self.position > 1 # We can't move something up if its at the top!
      tag_above = self.siblings.reject { |tag| tag.position != self.position - 1}[0]
      self.position, tag_above.position = tag_above.position, self.position
      [self,tag_above].each(&:save)
    end
  end

  def move_down
    if self.position < self.siblings.last.position
      tag_below = self.siblings.reject { |tag| tag.position != self.position + 1}[0]
      self.position, tag_below.position = tag_below.position, self.position
      [self,tag_below].each(&:save)
      return true
    end
  end

  def depth
    self.ancestors_count
  end
  
  def first?
    self.position == 1
  end
  
  def last?
    self.position > (self.siblings.map(&:position).max || 0)
  end
  # Not quite efficient yet, just does the job
  def self.parent_select_options
    options = [['-- No Parent --', nil]]
    Tag.recurse_for_parent_select_options(Tag.roots,options)
    return options
  end
  
  private

  def self.recurse_for_parent_select_options(nodes,options)
    nodes.each do |node|
      prefix = node.depth > 0 ? ' -' * node.depth + ' ' : ''
      options << [ prefix + node.title, node.id]
      Tag.recurse_for_parent_select_options(node.children,options)
    end
  end
end

#
# class Tag < ActiveRecord::Base

#   def self.create_auto_tag(reason = 'Import')
#     Tag.create(:tag => "Autotag: #{reason} - #{Time.now.to_s(:long)}", :parent => self.get_autotag_root_tag)
#   end
#
#   def self.get_special_root_tag
#     self.find(:first, :conditions => ['tag = ? and parent_id is null','Special'])
#   end
#
#   def self.get_uncategorized_root_tag
#     self.find(:first, :conditions => ['tag = ? and parent_id is null','Uncategorized'])
#   end
#
#   def self.get_autotag_root_tag
#     self.find(:first, :conditions => ['tag = ? and parent_id =?','Autotags',self.get_special_root_tag.id])
#   end
#
#   def name_for_display
#     self.hierarchical_title
#   end
#
#   def self.select_options
#      #YAGNI?
#   end
#
#   def self.recurse_for_select_options(tree,parent_id,depth,options)
#      #YAGNI?
#   end
