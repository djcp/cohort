class ContactEmail < ActiveRecord::Base

  EMAIL_TYPES = {'unknown' => 'Unknown', 'personal' => 'Personal', 'work' => 'Work'}

  validates_inclusion_of :email_type, :in => EMAIL_TYPES.keys
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  belongs_to :contact, :validate => true

  def self.options_for_select
    options = []
    EMAIL_TYPES.keys.each{|type|
      options << [EMAIL_TYPES[type], type]
    }
    return options
  end

end
