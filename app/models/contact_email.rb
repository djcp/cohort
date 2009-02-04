class ContactEmail < ActiveRecord::Base
  EMAIL_TYPES = {'personal' => 'Personal', 'work' => 'Work', 'unknown' => 'Unknown'}
  validates_inclusion_of :email_type, :in => EMAIL_TYPES.keys
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  belongs_to :contact
end
