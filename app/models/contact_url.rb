class ContactUrl < ActiveRecord::Base

  acts_as_ferret :single_index => true, :remote => true
  URL_TYPES = {'work' => 'Work','personal' => 'Personal','other' => 'Other','social' => 'Social Networking','blog' => 'Blog','rss' => 'RSS 2.0 Feed','atom' => 'Atom Feed'}

  has_many :log_items, :as => :item, :dependent => :destroy
  validates_inclusion_of :url_type, :in => URL_TYPES.keys

  belongs_to :contact, :validate => true

  def self.options_for_select
    options = []
    URL_TYPES.keys.each{|type|
      options << [URL_TYPES[type], type]
    }
    return options
  end

end
