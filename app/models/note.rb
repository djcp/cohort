class Note < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret :single_index => true, :remote => true, :additional_fields => [:my_contact, :my_user]
  include CohortArInstanceMixin
  extend CohortArClassMixin
  belongs_to :user
  belongs_to :contact
  has_many :log_items, :as => :item, :dependent => :destroy
  acts_as_list :scope => :contact_id

  def my_contact
    self.contact.name_for_display
  end

  def my_user
    self.user.username
  end

  def note_excerpt(length = 50)
    self.note and ((self.note.length > length) ? self.note[0..length] + '. . .' : self.note )
  end

  def follow_up_for_display
    self.follow_up.strftime('%b %d %Y at %I:%M%p')
  end

end
