# Include hook code here
Tag.class_eval do
  include CohortArInstanceMixin
  extend CohortArClassMixin
  has_many :log_items, :as => :item, :dependent => :destroy
end

Tagging.class_eval do
  include CohortArInstanceMixin
  extend CohortArClassMixin
end