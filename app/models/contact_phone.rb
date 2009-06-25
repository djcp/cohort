class ContactPhone < ActiveRecord::Base

  acts_as_ferret :single_index => true, :remote => true
  PHONE_TYPES = {'work' => 'Work', 'home' => 'Home', 'other' => 'Other', 'mobile' => 'Mobile', 'fax' => 'Fax' }

  has_many :log_items, :as => :item, :dependent => :destroy
  validates_inclusion_of :phone_type, :in => PHONE_TYPES.keys

  belongs_to :contact, :validate => true

  def self.options_for_select
    options = []
    PHONE_TYPES.keys.each{|type|
      options << [PHONE_TYPES[type], type]
    }
    return options
  end

end
