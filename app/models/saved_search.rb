class SavedSearch < ActiveRecord::Base
  belongs_to :user
  has_many :saved_search_runs

  validates_format_of :name, :with => /^[a-z\d\-\, ]+$/i, :message => 'should contain only letters, numbers, spaces, hyphens and commas.'

  def self.select_options(global_search = true,user_id = nil)
    category_conditions = []
    search_conditions = []
    if global_search == false
      category_conditions << 'select category from saved_searches where global_search is false and user_id = ? group by category order by category'
      category_conditions << user_id
      search_conditions << 'global_search is false and category = ? and user_id = ' + self.connection.quote(user_id)
    else
      category_conditions << 'select category,count(category) from saved_searches where global_search is true group by category order by category'
      search_conditions << 'category = ? and global_search is true'
    end
    search_cat = self.find_by_sql(category_conditions)
    grouped_options = [['',['-- select one --']]]
    search_cat.each do|cat|
      searches_in_cat = self.find(:all, :conditions => [search_conditions, cat.category].flatten, :order => :name)
      grouped_options << [cat.category,searches_in_cat.collect{|ss| [ss.name, ss.name]}]
    end
    return grouped_options
  end

end
