module CohortArMixin
  def forbid_delete_of_immutable_objects
    if self.immutable == true
      return false
    end
  end
end
