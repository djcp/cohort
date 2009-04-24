class Note < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret :single_index => true, :remote => true, :additional_fields => [:my_contact, :my_user]
  belongs_to :user
  belongs_to :contact
  has_many :log_items, :as => :item
  acts_as_list :scope => :contact_id

  def my_contact
    self.contact.name_for_display
  end

  def my_user
    self.user.username
  end

end
