class Contact < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  has_many :notes, :order => :position
  has_many :contact_emails
  has_and_belongs_to_many :tags
end
