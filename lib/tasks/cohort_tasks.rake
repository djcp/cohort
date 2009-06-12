## desc "Explaining what the task does"
#
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

#    import_tag = Tag.create(:title => 'Auto import')
    u = User.get_import_user

    FasterCSV.foreach("tmp/import.csv", {:headers => true,:header_converters => :symbol}) do |row|
      c = Contact.new
      rhash = row.to_hash
      columns.each do |col|
        c[col.to_sym] = rhash[col.to_sym]
      end
      if rhash[:notes] && ! rhash[:notes].strip.blank?
        c.notes << Note.new(:contact => c, :note => rhash[:notes], :user => u)
      end

      if rhash[:email] && ! rhash[:email].strip.blank?
        ce = ContactEmail.new(:is_primary => true, :email => rhash[:email].strip, :email_type => 'work')
        if ! ce.valid?
          puts "Invalid: #{ce.errors.full_messages.join(' ')}"
        else
          c.contact_emails << ce
        end
      end
#      c.tags << import_tag
      if c.valid?
        c.save
      else
        puts 'Invalid: ' + c.errors.full_messages.join(' ') 
      end
    end
    Contact.rebuild_index
    Note.rebuild_index
  end
  
end

