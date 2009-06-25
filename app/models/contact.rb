class Contact < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret(:single_index => true, :additional_fields => [:my_tags, :my_tag_ids, :my_emails, :my_notes, :my_addresses], :remote => true)
  acts_as_freetaggable
  include CohortArInstanceMixin
  extend CohortArClassMixin
  has_many :log_items, :as => :item, :dependent => :destroy
  has_many :notes, :order => 'position desc'

  has_many :contact_emails, :validate => true
  has_many :contact_urls, :validate => true
  has_many :contact_phones, :validate => true
  has_many :contact_addresses, :validate => true

  accepts_nested_attributes_for :contact_emails, :allow_destroy => true, 
    :reject_if => proc { |attributes| attributes['email'].blank? }
 
  accepts_nested_attributes_for :contact_addresses, :allow_destroy => true, 
    :reject_if => proc { |attributes| (attributes['city'].blank? or attributes['country'].blank?) ? true : false }

  accepts_nested_attributes_for :contact_urls, :allow_destroy => true, 
    :reject_if => proc { |attributes| attributes['url'].blank? }

  accepts_nested_attributes_for :contact_phones, :allow_destroy => true, 
    :reject_if => proc { |attributes| attributes['phone'].blank? }

  def name_for_display
    dname = [self.first_name, self.middle_name, self.last_name].flatten.join(' ')
    (dname.blank?) ? 'unknown' : dname
  end

  def primary_email
    pe = get_primary_email
    return pe && pe.email
  end

  def get_primary_email
    pe = self.contact_emails.find(:first, :order => 'is_primary desc, id')
  end

  def get_non_primary_emails
    pe = get_primary_email
    npes = self.contact_emails.collect do|npe|
      if npe != pe
        npe
      end
    end
    npes.compact!
  end

  def primary_phone 
    pp = get_primary_phone
    return pp && pp.phone
  end

  def get_primary_phone
    pp = self.contact_phones.find(:first, :order => 'is_primary desc, id')
  end

  def my_tags
    self.tags.collect{|t| t.title}.join(' ')
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

  def my_addresses
    self.contact_addresses.collect{|ca| "#{ca.street1} #{ca.street2} #{ca.city} #{ca.state} #{ca.zip} #{ca.country}"}.join(' ')
  end

end
