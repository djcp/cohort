class ContactAddress < ActiveRecord::Base

  acts_as_ferret :single_index => true, :remote => true
  ADDRESS_TYPES = {'unknown' => 'Unknown', 'personal' => 'Personal', 'work' => 'Work'}

  has_many :log_items, :as => :item, :dependent => :destroy
  validates_inclusion_of :address_type, :in => ADDRESS_TYPES.keys

  belongs_to :contact, :validate => true

  def self.options_for_select
    options = []
    ADDRESS_TYPES.keys.each{|type|
      options << [ADDRESS_TYPES[type], type]
    }
    return options
  end

end
