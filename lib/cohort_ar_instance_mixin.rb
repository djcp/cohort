module CohortArInstanceMixin

  def allow_delete_of_removable_objects
    if self.removable == false
      self.errors.add_to_base("This #{self.class.to_s.downcase} can't be deleted.")
      return false
    end
  end

  def updated_at_for_display
    self.updated_at.to_s(:compact_datetime)
  end

  def created_at_for_display
    self.created_at.to_s(:compact_datetime)
  end

  def diff_two_objects(object1 = self.new,object2 = self.new)

  end

end
