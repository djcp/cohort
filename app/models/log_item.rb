class LogItem < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  #Again, pretty much all validations are handled by the schema_validations plugin.
  
end
