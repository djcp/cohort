class ContactCartEntry < ActiveRecord::Base
  belongs_to :contact
  belongs_to :contact_cart
end
