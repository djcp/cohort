begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app. This is a dumb checker however; it is just requiring spec/spec_helper.rb"
  exit
end

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

# This is the new helper ^^^^^^
#  -- Not sure which one will work best
# This is the old helper VVVVVV

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'remarkable_rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = true
  config.fixture_path = File.dirname(__FILE__) + '/fixtures/'
end

def construct_tree
  # - root
  #     \---tag_one
  #      \--tag_two
  #           \--tag_two_one
  # - root2
  #     \---tag_three
  make = lambda { |title| Tag.create(:title => title)}
  # roots
  @root = make['Root']
  @root2 = make['Another Root']

  # @root children
  @tag_one = make['tag 1.1']
  @tag_two = make['tag 1.2']
  @root.children << [@tag_one, @tag_two]
  @tag_two_one = make ['tag 1.2.1']
  @tag_two.children << @tag_two_one

  @tag_three = make['tag 2.1']
  @root2.children << @tag_three

  @tags = [@root, @root2, @tag_one, @tag_two, @tag_two_one, @tag_three]
  @tags.each(&:save)
end
