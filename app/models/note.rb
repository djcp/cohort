class Note < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  belongs_to :user
  belongs_to :contact
  acts_as_list :scope => :contact_id
end
