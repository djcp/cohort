module CohortArClassMixin

  def recent_adds(limit = 5)
    includes = []
    includes = self.default_includes_by_class
    self.find(:all, :order => 'created_at desc', :include => includes, :limit => limit)
  end

  def my_recent_adds(user_id, limit = 5)
    return nil if user_id.blank?
    includes = self.default_includes_by_class
    self.find(:all, :conditions => ['user_id = ?',user_id], :include => includes, :order => 'created_at desc', :limit => limit)
  end

  def recent_updates(limit = 5)
    includes = self.default_includes_by_class
    self.find(:all, :order => 'updated_at desc', :include => includes, :limit => limit)
  end

  def my_recent_updates(user_id, limit = 5)
    return nil if user_id.blank?
    includes = self.default_includes_by_class
    self.find(:all, :conditions => ['user_id = ?',user_id], :include => includes, :order => 'updated_at desc', :limit => limit)
  end

  protected

  def default_includes_by_class
    includes = []
    if self.class_name == 'Note'
      includes = [:contact,:user]
    elsif self.class_name == 'Contact'
      includes = [:contact_emails, :notes, :tags]
    elsif self.class_name == 'Tagging'
      includes = [:freetaggable, :tag]
    end
    return includes
  end

end
