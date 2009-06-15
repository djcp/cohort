class Tagging < ActiveRecord::Base
  unloadable
  belongs_to :tag
  belongs_to :freetaggable, :polymorphic => true
end
