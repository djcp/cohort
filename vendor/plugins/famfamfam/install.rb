RAILS_ROOT = File.join( File.dirname(__FILE__), "..", "..", ".." ) unless defined? RAILS_ROOT

require "fileutils"

# Copy *.png icons to the public folder
target = File.join RAILS_ROOT, "public", "icons"
source = File.join File.dirname(__FILE__), "icons", "*.png"
FileUtils.mkdir target unless File.exist? target
puts "Coping png icons to public folder ..."
Dir[source].each do |png_file|
  FileUtils.cp png_file, target
end
puts "#{Dir[source].size} icons installed"

