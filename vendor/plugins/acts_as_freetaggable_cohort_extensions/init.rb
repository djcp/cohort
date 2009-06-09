# Include hook code here
Tag.class_eval do
  include CohortArInstanceMixin
  extend CohortArClassMixin
end

Tagging.class_eval do
  include CohortArInstanceMixin
  extend CohortArClassMixin
end