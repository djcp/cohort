module ActiveRecord
  module Acts
    module CategoryContent
      
      ###############
      # Constructor #
      ###############
      
      # This constructor is evoked when this module is included by <i>vendor/plugins/acts_as_category_content/init.rb</i>. That is, every time your Rails application is loaded, ActiveRecord is extended with the Acts::CategoryContent modules, and thus calls this constructor method.
      def self.included(base)
        # Add class methods module of Acts::CategoryContent to the superior class ActiveRecord
        # In that module, the InstanceMethods will be added as well
        base.extend(ClassMethods)
      end

      #######################
      # ClassMethods module #
      #######################
      
      module ClassMethods
        # Please refer to README for more information about this plugin.
        #
        # Configuration options are:
        #
        # * <tt>category</tt> - specifies the model name of the category (default: +category+)
        # * <tt>counter_cache</tt> - specifies the counter_cache to use (default: +pictures_count+)
        def acts_as_category_content(options = {})
    
          # Load parameters whenever acts_as_category is called
          configuration = { :category => 'category', :counter_cache => 'pictures_count' }
          configuration.update(options) if options.is_a?(Hash)
          
          belongs_to configuration[:category], :counter_cache => configuration[:counter_cache]
          
          validates_associated configuration[:category]
          validates_presence_of "#{configuration[:category]}_id", :message => I18n.t('acts_as_category_content.error.no_subcategories')
          
          # This class_eval contains methods which cannot be added wihtout having a concrete model.
          # Say, we want these methods to use parameters like "configuration[:category]", but we
          # don't have these parameters, unless somebody evokes the acts_as_category_content method in his
          # model. So we use class_eval, which generates methods, when acts_as_category_content is called,
          # and not already when our plugin's init.rb adds our Acts::CategoryContent modules to ActiveRecord.

          class_eval <<-EOV
          
            ##############################
            # Generated instance methods #
            ##############################
            
            # Inheriting category permitted? method
            def permitted?
              self.#{configuration[:category]}.permitted?
            end
            
            # In place version of permitted, returning self? Returns +false+ if not permitted
            def permitted!
              return self if self.permitted?
              false
            end

          EOV
        end
      end

    end
  end
end
