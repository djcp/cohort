class ContactCart < ActiveRecord::Base
  belongs_to :user
  has_many :contact_cart_entries, :dependent => :destroy
  has_many :contacts, :through => :contact_cart_entries
end
