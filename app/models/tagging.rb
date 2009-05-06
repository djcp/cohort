class Tagging < ActiveRecord::Base
  include CohortArInstanceMixin
  extend CohortArClassMixin
  belongs_to :contact
  belongs_to :tag
end
