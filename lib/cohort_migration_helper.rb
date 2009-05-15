class CohortMigrationHelper

  def self.init_helper_class(connection)
    migration_extension_class_name = "CohortMigration#{connection.adapter_name.capitalize}"
    begin
      require migration_extension_class_name.tableize.singularize
      helper_class = Object.const_get(migration_extension_class_name)
      helper_class.can_be_extended?(connection) ? helper_class : false
    rescue Exception
      return false
    end
  end

end
