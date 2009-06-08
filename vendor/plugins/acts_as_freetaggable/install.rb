require 'ftools'
# Install hook code here
puts "Installing ActsAsFreetaggable...\n"

# Ugh, script/plugin is hard to test without pushing to a repo. Copy-paste from rake task :(
# Make symlinks for acts_as_category and has_many_polymorphs unless they exist
puts "Symlinking plugins to RAILS_ROOT/vendor/plugins..."
Dir["#{File.dirname(__FILE__)}/vendor/plugins/*"].each do |plugin_path|
  plugin = plugin_path.split('/').last
  target = Rails.root + "vendor/plugins/#{plugin}"
  if target.exist?
    puts " #{plugin} already exists, skipping."
  else
    puts " Symlinked \n\t#{plugin_path}\n to\n\t#{target}"
    target.make_symlink(plugin_path)
  end
end

# Generate db migration for tag and taggings?
puts "Copy migrations from the ActsAsFreetaggable plugin to your local rails migrations folder"
FileUtils.mkdir_p "#{RAILS_ROOT}/db/migrate"
Dir["#{File.dirname(__FILE__)}/db/migrate/*.rb"].each do |migration_path|
  migration = migration_path.split('/').last
  new_path = "#{RAILS_ROOT}/db/migrate/#{migration}"
  File.copy( migration_path, new_path)
  puts " Copied \"#{migration}\" to #{new_path}"
end
