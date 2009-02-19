class Contact < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret :single_index => true, :remote => true
  has_many :notes, :order => 'position desc'
  has_many :contact_emails, :validate => true
  has_and_belongs_to_many :tags

  def name_for_display
    [self.first_name, self.last_name, ((self.contact_emails && self.contact_emails.first) ? [' - ', self.contact_emails.first.email] : '')].flatten.join(' ')
  end

  def primary_email
    pe = self.contact_emails.find(:first, :conditions => ['is_primary is true'])
    return pe && pe.email
  end
end
