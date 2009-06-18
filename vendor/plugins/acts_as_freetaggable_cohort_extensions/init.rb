# Include hook code here
Tag.class_eval do
  unloadable
  include CohortArInstanceMixin
  extend CohortArClassMixin
  has_many :log_items, :as => :item, :dependent => :destroy

  before_destroy :allow_delete_of_removable_objects

  def name_for_display
    "#{self.hierarchical_title}"
  end
  
  def move_higher
    self.move_up
  end

  def move_lower
    self.move_down
  end
  

end

Tagging.class_eval do
  unloadable
  include CohortArInstanceMixin
  extend CohortArClassMixin
end
