module ActiveRecord
  # Get the power of ActiveRecord models, including validation, without having a table in the database.
  #
  # == Usage
  #
  #   class Contact < ActiveRecord::BaseWithoutTable
  #     column :name, :text
  #     column :email_address, :text
  #     column :message, :text
  #   end
  #
  #   validates_presence_of :name, :email_address, :string
  #
  # This model can be used just like a regular model based on a table, except it will never be saved to the database.
  #
  class BaseWithoutTable < Base
    self.abstract_class = true

    class << self
      def connection
        Class.new(SimpleDelegator) do
          def schema_cache
            Class.new do
              def columns(*args)
                []
              end

              def columns_hash(*args)
                {}
              end
            end.new
          end
        end.new(super)
      end

      def table_exists?
        false
      end

      def inherited(subclass)
        subclass.define_singleton_method(:table_name) do
          "activerecord_base_without_table_#{subclass.name}"
        end
        super(subclass)
      end

      def attribute_names
        _default_attributes.keys.map(&:to_s)
      end

      def column(name, sql_type = nil, default = nil, null = true) # :nodoc:
        # do not use << in here. See: http://apidock.com/rails/Class/class_attribute

        # This is an emulation of the Rails 4.1 runtime behaviour.
        # Please consider rewriting once we move to Rails 5.
        mapped_sql_type = case sql_type
        when :datetime
          :date_time
        when :datetime_point
          :integer
        when :enumerable
          :value
        else
          sql_type
        end.to_s

        cast_type = "ActiveRecord::Type::#{mapped_sql_type.camelize}".constantize.new

        define_attribute(name.to_s, cast_type, default: default)
      end

      def build_column_types
        self.class.columns.reduce({}) do |acc, column|
          acc.merge(column.name.to_s => column.sql_type_metadata)
        end
      end

      def lookup_column_type(sql_type)
        # This is copy-pasted from ActiveRecord::BaseWithoutTable, please find another approach.
        mapped_sql_type = case sql_type
                          when :datetime
                            :date_time
                          when :datetime_point
                            :integer
                          when :enumerable
                            :value
                          else
                            sql_type
                          end.to_s
                          "::ActiveRecord::Type::#{mapped_sql_type.camelize}".constantize.new
      end

      def gettext_translation_for_attribute_name(attribute)
        # `rake gettext:store_model_attributes` processes our BaseWithoutTable models, but we have our own rake task
        # for that. Return right away if calling gettext_translation_for_attribute_name on BaseWithoutTable
        return "BaseWithoutTable" if self == BaseWithoutTable

        attribute = attribute.to_s
        if attribute.ends_with?("_id")
          humanize_class_name(attribute)
        else
          "#{inheritance_class_owner(attribute)}|#{attribute.split('.').map!(&:humanize).join('|')}"
        end
      end

      def inheritance_class_owner(attribute)
        superclass = self.superclass
        if superclass.attribute_names.include?(attribute)
          superclass.inheritance_class_owner(attribute)
        else
          self
        end
      end
    end
  end
end
