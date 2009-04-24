class LogItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  
end
