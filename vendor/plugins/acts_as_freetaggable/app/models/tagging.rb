class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :freetaggable, :polymorphic => true
end
