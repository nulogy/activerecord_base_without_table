# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    # When run against a real database backend, ordinarily the SchemaCache
    # would open a connection to the DB and attempt to retrieve schema
    # information from it.
    #
    # Here, we declare that these ActiveRecord classes do not have any
    # database-backed schema or column information. The structure of an
    # ActiveRecord::BaseWithoutTable is purely an in-memory construct
    # and is defined through the use of the `column` class methods.
    class NullSchemaCache
      def columns(*args)
        []
      end

      def columns_hash(*args)
        {}
      end
    end
  end
end
