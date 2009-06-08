module ActiveRecord
  module Acts
    module Category
      
      ###############
      # Constructor #
      ###############
      
      # This constructor is evoked when this module is included by <i>vendor/plugins/acts_as_category/init.rb</i>. That is, every time your Rails application is loaded, ActiveRecord is extended with the Acts::Category modules, and thus calls this constructor method.
      def self.included(base)
        # Add class methods module of Acts::Category to the superior class ActiveRecord
        # In that module, the InstanceMethods will be added as well
        base.extend ClassMethods
      end

      #######################
      # ClassMethods module #
      #######################
      
      module ClassMethods        
        # Please refer to README for more information about this plugin.
        #
        #  create_table "categories", :force => true do |t|
        #    t.integer "parent_id"
        #    t.integer "position"
        #    t.boolean "hidden"
        #    t.integer "children_count"
        #    t.integer "ancestors_count"
        #    t.integer "descendants_count"
        #  end
        #
        # Configuration options are:
        #
        # * <tt>foreign_key</tt> - specifies the column name to use for tracking of the tree (default: +parent_id+)
        # * <tt>position</tt> - specifies the integer column name to use for ordering siblings (default: +position+)
        # * <tt>hidden</tt> - specifies a column name to use for hidden flag (default: +hidden+)
        # * <tt>children_count</tt> - specifies a column name to use for caching number of children (default: +children_count+)
        # * <tt>ancestors_count</tt> - specifies a column name to use for caching number of ancestors (default: +ancestors_count+)
        # * <tt>descendants_count</tt> - specifies a column name to use for caching number of descendants (default: +descendants_count+)
        def acts_as_category(options = {})
        
          # Load parameters whenever acts_as_category is called
          configuration = { :foreign_key => "parent_id", :position => "position", :hidden => "hidden", :children_count => 'children_count', :ancestors_count => 'ancestors_count', :descendants_count => 'descendants_count' }
          configuration.update(options) if options.is_a?(Hash)
          
          # Create a class association to itself
          belongs_to :parent, :class_name => name, :foreign_key => configuration[:foreign_key], :counter_cache => configuration[:children_count]
          has_many :children, :class_name => name, :foreign_key => configuration[:foreign_key], :order => configuration[:position], :dependent => :destroy

          # Substantial validations
          before_validation :validate_foreign_key
          before_validation_on_create :assign_position
          validates_numericality_of configuration[:foreign_key], :only_integer => true, :greater_than => 0, :allow_nil => true, :message => I18n.t('acts_as_category.error.no_descendants')
          validates_numericality_of configuration[:position],    :only_integer => true, :greater_than => 0

          # Callbacks for automatic refresh of ancestors_count & descendants_count cache columns
          after_create :refresh_cache_after_create
          before_update :prepare_refresh_before_update
          after_update :refresh_cache_after_update
          before_destroy :prepare_refresh_before_destroy
          after_destroy :refresh_cache_after_destroy

          # Add readonly attribute to cache columns
          # Note that children_count is automatically readonly
          #attr_readonly configuration[:ancestors_count]   if column_names.include? configuration[:ancestors_count]
          #attr_readonly configuration[:descendants_count] if column_names.include? configuration[:descendants_count]

          # Define class variables
          class_variable_set :@@permissions, []
          
          #################
          # Class methods #
          #################

          # Returns an +array+ with +ids+ of categories, which are to be allowed to be seen, though they might be hidden. Returns an empty +array+ if none.
          # The idea is, to define a class variable array +permissions+ each time the user logs in (which is job of the controller, in case you would like to use this functionality).
          def self.permissions
            class_variable_get :@@permissions
          end
      
          # Takes an +array+ of +ids+ of categories and defines them to be permitted.
          # Note that this overwrites the array with each call, instead of adding further ids to it.
          def self.permissions=(ids)
            permissions = []
            ids.each { |id| permissions << id.to_i if id.to_i > 0 } if ids.is_a?(Array)
            class_variable_set :@@permissions, permissions.uniq
          end
          
          # This class_eval contains methods which cannot be added wihtout having a concrete model.
          # Say, we want these methods to use parameters like "configuration[:foreign_key]", but we
          # don't have these parameters, unless somebody evokes the acts_as_category method in his
          # model. So we use class_eval, which generates methods, when acts_as_category is called,
          # and not already when our plugin's init.rb adds our Acts::Category modules to ActiveRecord.
          # Another example is, that we want to overwrite the association method "children", but this
          # association doesn't exist before acts_as_category is actually called. So we need class_eval.

          class_eval <<-EOV

            ##############################
            # Generated instance methods #
            ##############################
            
            include ActiveRecord::Acts::Category::InstanceMethods
                        
            # Define instance getter and setter methods to keep track of the option parameters
            def parent_id_column() '#{configuration[:foreign_key]}' end
            def parent_id_column=(id) write_attribute('#{configuration[:foreign_key]}', id) end
            def position_column() '#{configuration[:position]}' end
            def position_column=(pos) write_attribute('#{configuration[:position]}', pos) end
            def hidden_column() '#{configuration[:hidden]}' end
            def children_count_column() '#{configuration[:children_count]}' end
            def ancestors_count_column() '#{configuration[:ancestors_count]}' end
            def descendants_count_column() '#{configuration[:descendants_count]}' end

            # Overwrite the children association method, so that it will respect permitted/hidden categories
            # Note: If you ask about the children of a not-permitted category, the result will be an empty array in any case
            alias :orig_children :children
            def children
              result = orig_children
              result.delete_if { |child| !child.permitted? }
              result
            end

            ###########################
            # Generated class methods #
            ###########################
                
            # Update cache columns of a whole branch, which includes the given +category+ or its +id+.
            def self.refresh_cache_of_branch_with(category)
              category = find(category) unless category.instance_of?(self)   # possibly convert id into category
              root = category.#{configuration[:foreign_key]}.nil? ? category : category.root   # find root of category (if not already)
              root.refresh_cache
              root.descendants.each { |d| d.refresh_cache }
            end

            # Creates a WHERE clause for SQL statements, which causes forbidden categories not to be included. Adds AND statement if parameter +true+ is given.
            #  where_permitted       #=> " (NOT hidden OR id IN (1,2,3)) "
            #  where_permitted       #=> " (NOT hidden) " # whenver @@permissions is empty
            #  where_permitted(true) #=> " AND (NOT hidden OR id IN (1,2,3)) "
            #  where_permitted(true) #=> " AND (NOT hidden) " # whenver @@permissions is empty
            def self.where_permitted(with_and = false)
              id_addon = (class_variable_get :@@permissions).size == 0 ? '' : " OR id IN (\#{(class_variable_get :@@permissions).join(',')})"
              "\#{with_and ? ' AND' : ''} (#{configuration[:hidden]} IS NULL\#{id_addon}) "
            end
            
            # Returns the +category+ to a given +id+. This is as a replacement for find(id), but it respects permitted/hidden categories.
            def self.get(id)
              find(:first, :conditions => 'id = ' + id.to_i.to_s + where_permitted(true))
            end
            
            # Returns all root +categories+, respecting permitted/hidden ones
            def self.roots(ignore_permissions = false)
              where_clause = ignore_permissions ? '' : where_permitted(true)
              find(:all, :conditions => '#{configuration[:foreign_key]} IS NULL' + where_clause, :order => #{configuration[:position].nil? ? 'nil' : %Q{"#{configuration[:position]}"}})
            end
            
            # Receives the controller's +params+ variable and updates category positions accordingly.
            # Please refer to the helper methods that came with this model for further information.
            def self.update_positions(params)
              params.each_key { |key|
                if key.include?('aac_sortable_tree_')
                  parent_id = key.split('_').last.to_i
                  params[key].each_with_index { |id, position|
                    category = find(id)
                    # Verify that every category is valid and from the correct parent
                    #logger.debug "ACTS_AS_CATEGORY: Processing \#{category.inspect}"
                    raise ArgumentError, 'Invalid attempt to update a category position: Cannot update a category (ID '+category.id.to_s+') out of given parent_id (ID '+parent_id.to_s+')' unless category.#{configuration[:foreign_key]}.nil? && parent_id == 0 || parent_id > 0 && category.#{configuration[:foreign_key]} == parent_id
                    @counter = position + 1
                  }
                  self_and_siblings_count = parent_id <= 0 ? roots.size : find(parent_id).children.count
                  # Verify that the parameters correspond to every child of this parent
                  raise ArgumentError, 'Invalid attempt to update a category position: Number of category IDs in param hash is wrong ('+@counter.to_s+' instead of '+self_and_siblings_count.to_s+' for parent with ID '+parent_id.to_s+')' unless @counter == self_and_siblings_count
                  # Do the actual position update
                  params[key].each_with_index { |id, position| find(id).update_attribute('#{configuration[:position]}', position + 1)}
                  end
              }
              rescue ActiveRecord::RecordNotFound
              raise ArgumentError, 'Invalid attempt to update a category position: Parent category does not exist'
            end

            # Updating all category positions into correct 1, 2, 3 etc. per hierachy level
            def self.refresh_positions(categories = nil)
              categories = roots if categories.blank?
              categories = [categories] unless categories.is_a? Array
              categories.each_with_index { |category, position|
                category.update_attribute('#{configuration[:position]}', position + 1)
                refresh_positions(category.children) unless category.children.empty?
              }
            end
            
          EOV
        end
      end

      ##########################
      # InstanceMethods module #
      ##########################
      
      module InstanceMethods
        
        ####################
        # Instance methods #
        ####################

        # Returns +true+ if category is visible/permitted, otherwise +false+.
        def permitted?
          return false if self.class.find(self.id).read_attribute(hidden_column) and !self.class.permissions.include?(self.id)          
          node = self
          while node.parent do
            node = node.parent
            return false if self.class.find(node.id).read_attribute(hidden_column) and !self.class.permissions.include?(node.id)
          end
          true
        end

        # Returns +array+ of children's ids, respecting permitted/hidden categories
       	def children_ids
       	  children_ids = []
          self.children.each { |child| children_ids << child.id if child.permitted? } unless self.children.empty?
          children_ids
        end

        # Returns list of ancestors, disregarding any permissions
        def ancestors
          node, nodes = self, []
          nodes << node = node.parent while node.parent
          nodes
        end

        # Returns array of IDs of ancestors, disregarding any permissions
       	def ancestors_ids
          node, nodes = self, []
          while node.parent
            node = node.parent
            nodes << node.id
          end
          nodes
        end

        # Returns list of descendants, respecting permitted/hidden categories
       	def descendants
       	  descendants = []
       	  self.children.each { |child|
       	    descendants += [child] if child.permitted?
       	    descendants += child.descendants
       	  } unless self.children.empty?
       	  descendants 
       	end

       	# Returns array of IDs of descendants, respecting permitted/hidden categories
       	def descendants_ids(ignore_permissions = false)
       	  descendants_ids = [] 
       	  self.children.each { |child|
       	    descendants_ids += [child.id] if ignore_permissions or child.permitted?
       	    descendants_ids += child.descendants_ids
       	  } unless self.children.empty?
       	  descendants_ids
       	end

        # Returns the root node of the branch, disregarding any permissions
        def root
          node = self
          node = node.parent while node.parent
          node
        end
        
        # Returns +true+ if category is root, otherwise +false+, disregarding any permissions
        def root?
          self.parent ? false : true
        end

        # Returns all siblings of the current node, respecting permitted/hidden categories
        def siblings
          result = self_and_siblings - [self]
          result.delete_if { |sibling| !sibling.permitted? }
          result
        end

        # Returns all siblings and a reference to the current node, respecting permitted/hidden categories
        def self_and_siblings
          parent ? parent.children : self.class.roots
        end

        # Returns all ids of siblings and a reference to the current node, respecting permitted/hidden categories
        def self_and_siblings_ids
          parent ? parent.children_ids : self.class.roots.map {|x| x.id}
        end
        
        # Immediately refresh cache of category instance
        def refresh_cache
          self.class.connection.execute "UPDATE #{self.class.table_name} SET #{ancestors_count_column}=#{self.ancestors.size},  #{descendants_count_column}=#{self.descendants.size} WHERE id=#{self.id}"
        end
        
        ############################
        # Private instance methods #
        ############################

        private
        
        # Validator for parent_id association after creation and update of a category
        def validate_foreign_key
          # If there is a parent_id given
          unless self.read_attribute(parent_id_column).nil?
            # Parent_id must be a valid category ID
            self.write_attribute(parent_id_column, 0) if self.read_attribute(parent_id_column) > 0 && !self.class.find(self.read_attribute(parent_id_column))
            # Parent must not be itself
            self.write_attribute(parent_id_column, 0) if self.read_attribute(parent_id_column) > 0 && self.id == self.read_attribute(parent_id_column) unless self.id.blank?
            # Parent must not be a descendant of itself
            self.write_attribute(parent_id_column, 0) if self.read_attribute(parent_id_column) > 0 && self.descendants_ids(true).include?(self.read_attribute(parent_id_column))
          end
          rescue ActiveRecord::RecordNotFound
          self.write_attribute(parent_id_column, 0) # Parent was not found
        end
        
        # Assigns a position integer after creation of a category
        def assign_position
          # Position for new nodes is (number of siblings + 1), but only for new categories
          if self.read_attribute(parent_id_column).nil?
            self.write_attribute(position_column, self.class.roots(true).size + 1)
          else
            self.write_attribute(position_column, self.class.find(:all, :conditions => ["#{parent_id_column} = ?", self.read_attribute(parent_id_column)]).size + 1)
          end
        end
        
        # Refresh cache of branch of created category instance
        def refresh_cache_after_create
          self.class.refresh_cache_of_branch_with(self.root)
        end
        
        # Gather parent_id before any manipulation
        def prepare_refresh_before_update
          @parent_id_before = self.class.find(self.id).read_attribute(parent_id_column)
        end
        
        # A category has been manipulated, refresh cache columns
        def refresh_cache_after_update
          # Parent didn't change, do nothing with cache
          return if @parent_id_before == self.read_attribute(parent_id_column)
          # If a subcategory has come from another branch, refresh that tree
          self.class.refresh_cache_of_branch_with(@parent_id_before) unless @parent_id_before.nil? || @parent_id_before == self.root.id
          # Refresh current branch in any case
          self.class.refresh_cache_of_branch_with(self.root)
          # Refresh all positions
          self.class.refresh_positions
        end
        
        # Gather root.id before destruction
        def prepare_refresh_before_destroy
          @root_id_before = self.root.id
        end
        
        # Refresh cache of branch, where category has been destroyed, unless it was a root
        def refresh_cache_after_destroy
          self.class.refresh_cache_of_branch_with(@root_id_before) if self.class.find(@root_id_before)
          rescue ActiveRecord::RecordNotFound
        end
        
      end
    end
  end
end
