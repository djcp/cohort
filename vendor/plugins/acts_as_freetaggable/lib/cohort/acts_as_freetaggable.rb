# ActsAsFreetaggable
module Cohort
  module ActsAsFreetaggable
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_freetaggable(options={})
        klass = self.to_s.pluralize.underscore.to_sym
        Tag.class_eval do
          has_many_polymorphs :freetaggables, :from => [klass], :through => :taggings
        end
        self.class_eval do
          has_many :taggings, :as => :freetaggable, :dependent => :destroy
          has_many :tags, :through => :taggings
        end
      end
    end
  end
end
