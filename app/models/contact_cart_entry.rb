# Contact cart entry is the join table between a Contact and a ContactCart
class ContactCartEntry < ActiveRecord::Base
  belongs_to :contact
  belongs_to :contact_cart
end
