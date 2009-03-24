class SavedSearch < ActiveRecord::Base
  belongs_to :user
  has_many :saved_search_runs

  def self.select_options
    search_cat = self.find_by_sql('select category,count(category) from saved_searches group by category order by category')
    grouped_options = [['',['-- select one --']]]
    search_cat.each do|cat|
      searches_in_cat = self.find(:all, :conditions => ['category = ?', cat.category], :order => :name)
      grouped_options << [cat.category,searches_in_cat.collect{|ss| [ss.name, ss.id.to_s]}]
    end
    return grouped_options
  end

end
