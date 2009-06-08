class Tagging < ActiveRecord::Base
  include CohortArInstanceMixin
  extend CohortArClassMixin
end