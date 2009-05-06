module CohortArClassMixin

  def recent_adds(limit = 5)
    self.find(:all, :order => 'created_at desc', :limit => limit)
  end

  def my_recent_adds(user_id, limit = 5)
    return nil if user_id.blank?
    self.find(:all, :conditions => ['user_id = ?',user_id], :order => 'created_at desc', :limit => limit)
  end

  def recent_updates(limit = 5)
    self.find(:all, :order => 'updated_at desc', :limit => limit)
  end

  def my_recent_updates(user_id, limit = 5)
    return nil if user_id.blank?
    self.find(:all, :conditions => ['user_id = ?',user_id], :order => 'updated_at desc', :limit => limit)
  end
end
