RAILS_ROOT = File.join( File.dirname(__FILE__), "..", "..", ".." ) unless defined? RAILS_ROOT

require "fileutils"

target_dir = File.join RAILS_ROOT, "public", "icons"
puts "Removing png icons from public folder ..."
Dir[source].each do |png_file|
  target = File.join target_dir, File.basename(png_file)
  FileUtils.rm target
end
puts "Removing icons folder unless not empty"
FileUtils.rmdir target_dir

