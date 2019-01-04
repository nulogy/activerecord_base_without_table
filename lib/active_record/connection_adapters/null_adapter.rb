# frozen_string_literal: true

# This class is a concrete implementation of ConnectionAdapters::AbstractAdapter
# that eliminates all code paths attempting to open a connection to a real
# database backend.
module ActiveRecord
  module ConnectionAdapters
    class NullAdapter < SimpleDelegator
      def schema_cache
        NullSchemaCache.new
      end
    end
  end
end
