class Contact < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  has_many :notes, :order => :position
  has_many :contact_emails, :validate => true
  has_and_belongs_to_many :tags

  def name_for_display
    [self.first_name, self.last_name].join(' ')
  end

  def primary_email
    pe = self.contact_emails.find(:first, :conditions => ['is_primary is true'])
    return pe && pe.email
  end
end
