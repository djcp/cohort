# Include hook code here
Tag.class_eval do
  unloadable
  include CohortArInstanceMixin
  extend CohortArClassMixin
  has_many :log_items, :as => :item, :dependent => :destroy

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
