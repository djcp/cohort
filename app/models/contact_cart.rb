class ContactCart < ActiveRecord::Base
  belongs_to :user
  has_many :contact_cart_entries, :dependent => :destroy
  has_many :contacts, :through => :contact_cart_entries

  def contact_names
    contacts.count == 0 ? ' -- None Added -- ' : contacts.map(&:name_for_display).join(', ').squeeze(' ')
  end
  
  def title
    self[:title] || ' -- None Given -- '
  end
end
