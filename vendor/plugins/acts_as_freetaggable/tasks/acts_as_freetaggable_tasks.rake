require 'ftools'

namespace :freetaggable do
  desc "Complete the necessary steps to install ActsAsFreetaggable"
  task :install => [:symlink_plugins, :copy_migrations]

  desc "Symlink ActsAsFreetaggable's plugins to your vendor/plugins folder -- unless they already exist"
  task :symlink_plugins => :environment do # this doesn't really _need_ environment but not sure how to get Rails.root otherwise
    puts "Symlinking plugins to RAILS_ROOT/vendor/plugins..."
    Dir["#{File.dirname(__FILE__)}/../vendor/plugins/*"].each do |plugin_path|
      plugin = plugin_path.split('/').last
      target = Rails.root + "vendor/plugins/#{plugin}"
      if target.exist?
        puts " #{plugin} already exists, skipping."
      else
        puts " Symlinked \n\t#{plugin_path}\n to\n\t#{target}"
        target.make_symlink(plugin_path)
      end
    end
  end
  desc "Copy migrations from the ActsAsFreetaggable plugin."
  task :copy_migrations do
    puts "Copy migrations from the ActsAsFreetaggable plugin to your local rails migrations folder"
    FileUtils.mkdir_p "#{RAILS_ROOT}/db/migrate"
    Dir["#{File.dirname(__FILE__)}/../db/migrate/*.rb"].each do |migration_path|
      migration = migration_path.split('/').last
      new_path = "#{RAILS_ROOT}/db/migrate/#{migration}"
      File.copy( migration_path, new_path)
      puts " Copied \"#{migration}\" to #{new_path}"
    end
  end

  desc "Test the ActsAsFreetaggable plugin. Must have blank Comment and Contact models"
  task :specs do
    puts `spec -O #{File.dirname(__FILE__)}/../spec/spec.opts #{File.dirname(__FILE__)}/../spec/**/*_spec.rb`
  end
end
