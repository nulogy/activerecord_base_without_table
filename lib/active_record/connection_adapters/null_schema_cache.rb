# frozen_string_literal: true

#
# When run against a real database backend, ordinarily the SchemaCache
# would open a connection to the DB and attempt to retrieve schema
# information from it.
#
# Here, we declare that these ActiveRecord classes do not have any
# database-backed schema or column information. The structure of an
# ActiveRecord::BaseWithoutTable is purely an in-memory construct
# and is defined through the use of the `column` class methods.
#
module ActiveRecord
  module ConnectionAdapters
    class NullSchemaCache
      # Callers operate with no columns.
      def columns(*)
        []
      end

      # Callers operate with no columns.
      def columns_hash(*)
        {}
      end

      # Callers consider the columns cached.
      def columns_hash?(*)
        true
      end
    end
  end
end
