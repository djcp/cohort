class Contact < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret(:single_index => true, :additional_fields => [:my_tags, :my_tag_ids, :my_emails, :my_notes], :remote => true)
  has_many :notes, :order => 'position desc'
  has_many :contact_emails, :validate => true
  has_and_belongs_to_many :tags

  def name_for_display
    [self.first_name, self.last_name, ((self.contact_emails && self.contact_emails.first) ? [' - ', self.contact_emails.first.email] : '')].flatten.join(' ')
  end

  def primary_email
    pe = get_primary_email 
    return pe && pe.email
  end

  def get_primary_email
    pe = self.contact_emails.find(:first, :conditions => ['is_primary is true'])
  end

  def my_tags
    self.tags.collect{|t| t.tag}.join(' ')
  end

  def my_notes
    self.notes.collect{|n| n.note}.join(' ')
  end


  def my_tag_ids
    self.tags.collect{|t| t.id}.join(' ')
  end

  def my_emails
    self.contact_emails.collect{|e| e.email}.join(' ')
  end

end
