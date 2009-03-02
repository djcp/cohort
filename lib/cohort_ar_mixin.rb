module CohortArMixin
  def forbid_delete_of_immutable_objects
    if self.immutable == true
      self.errors.add_to_base("This #{self.class.to_s.downcase} can't be deleted.")
      return false
    end
  end
end
