class Tagging < ActiveRecord::Base
  belongs_to :contact
  belongs_to :tag
end
