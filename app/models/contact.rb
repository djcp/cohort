class Contact < ActiveRecord::Base
  
  # Mail campaign Assoc.
  has_many :freemailer_campaign_contacts, :dependent => :destroy
  has_many :freemailer_campaigns, :through => :freemailer_campaign_contacts
  
  has_many :contact_cart_entries, :dependent => :destroy
  has_many :contact_carts, :through => :contact_cart_entries
    
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret(:single_index => true, :additional_fields => [:my_tags, :my_tag_ids, :my_emails, :my_notes, :my_addresses, :my_urls], :remote => true)
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

  def hash_for_duplicate_detection
    hash = { 
      :addresses => get_primary_address(:all),
      :emails => get_primary_email(:all),
      :phone_numbers => get_primary_phone(:all)
    }
  end

  def name_for_display
    dname = [self.first_name, self.middle_name, self.last_name].flatten.compact.join(' ')
    (dname.blank?) ? 'unknown' : dname
  end

  def primary_address
    pa = get_primary_address
    return pa && "#{pa.street1}\n" + "#{if !pa.street2.squeeze.empty?; pa.street2 + "\n"; end;}" + 
      "#{pa.city}, #{pa.state}  #{pa.zip}\n#{pa.country}"
  end

  def get_primary_address(amount=:first)
    pa = self.contact_addresses.find(amount, :order => 'is_primary desc, id')
  end

  def email(which=:primary)
    if which == :primary
      self.contact_emails.find(:first, :order => 'is_primary desc, id')
    else
      all = self.contact_emails.find(:all, :order => 'is_primary desc, id')
      if which == :non_primaries
        all.shift
      elsif which == :all
        all
      end
    end
  end

  def get_primary_email(amount=:first)
    pe = self.contact_emails.find(amount, :order => 'is_primary desc, id')
  end

  def primary_phone 
    pp = get_primary_phone
    return pp && pp.phone
  end

  def get_primary_phone(amount=:first)
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

  def my_urls
    self.contact_urls.collect{|cu| "#{cu.url}"}.join(' ')
  end

end
