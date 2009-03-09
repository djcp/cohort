class SavedSearch < ActiveRecord::Base
  belongs_to :user
  has_many :saved_search_runs

end
