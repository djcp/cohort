# desc "Explaining what the task does"
# task :fckeditor do
#   # Task goes here
# end

namespace :cohort do
  def setup 
    require 'fastercsv'
  end
  
  desc 'Import sample data'
  task (:import => :environment) do
    setup
    columns = Contact.columns.collect{|c| c.name}
    columns.delete('id')
    FasterCSV.foreach("tmp/import.csv", {:headers => true,:header_converters => :symbol}) do |row|
      c = Contact.new
      rhash = row.to_hash
      columns.each do |col|
        c[col.to_sym] = rhash[col.to_sym]
      end
      if c.valid?
        c.save
      else
        puts 'Invalid: ' + c.errors.full_messages.join(' ') 
      end
    end
  end
  
end

