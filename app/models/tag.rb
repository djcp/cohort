class Tag < ActiveRecord::Base
  include CohortArInstanceMixin
  extend CohortArClassMixin
end