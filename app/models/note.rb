class Note < ActiveRecord::Base
  # Many validations are handled by the redhill schema_validations plugin.
  acts_as_ferret :single_index => true, :remote => true
  belongs_to :user
  belongs_to :contact
  acts_as_list :scope => :contact_id

  def self.full_text_search(q, options = {})
    return nil if q.blank?
    default_options = {:limit => 10, :page => 1}
    options = default_options.merge options
    options[:offset] = options[:limit] * (options.delete(:page).to_i-1)
    results = self.find_by_contents("#{q}", options)
    return [results.total_hits, results]
  end

end
