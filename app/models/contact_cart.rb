# Holds references to a user who owns the cart, and any number of Contacts belonging to the cart.
#
# At the moment is used by FreemailerCampaignController to build mail campaigns
class ContactCart < ActiveRecord::Base
  belongs_to :user
  has_many :contact_cart_entries, :dependent => :destroy
  has_many :contacts, :through => :contact_cart_entries

  # Provides a list of contacts in the cart joined by ", " or " -- None Added -- " if there are no contacts.
  def contact_names
    contacts.count == 0 ? ' -- None Added -- ' : contacts.map(&:name_for_display).join(', ').squeeze(' ')
  end
  
  # The title of the cart or " -- None Given -- " if absent.
  def title
    self[:title] || ' -- None Given -- '
  end
end
