# frozen_string_literal: true

# This class exists to support the use of `find_by_sql` on BaseWithoutTable
# instances. It is highly aware of internal implementation details of
# ActiveRecord.
#
# It ensures that Attributes that have been decorated
# (e.g. with time zone conversion decorators) at class method evaluation
# time do not lose their decoration when BaseWithoutTable instances are
# brought to life via `#instantiate` (by way of `#find_by_sql`).
#
# This occurs when ActiveRecord needs to synthesize Attributes for
# `additional_types` that are not part of the record's schema, which may
# result from joining in columns from an associated relation in a raw SQL
# query.
#
# Since the NullSchemaCache declares that the record has no schema,
# all `additional_types` are in need of an Attribute to represent them.
# However, creating them would clobber the Attributes that were already
# constructed in the evaluation of the `BaseWithoutTable::column`
# class method, and remove the decoration that was applied to them at that
# time.
module ActiveRecord
  class AttributesBuilderWithoutTable < SimpleDelegator
    def build_from_database(values = {}, _additional_types = {})
      super(values, {})
    end
  end
end
