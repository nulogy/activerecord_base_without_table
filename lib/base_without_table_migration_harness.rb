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

    class_attribute :columns
    self.columns = []

    def create_or_update # :nodoc:
      errors.empty?
    end

    class << self
      def column_defaults
        columns.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |current, res|
          res[current.name] = current.default
        end
      end

      def columns_hash
        all_columns = add_user_provided_columns(columns)

        @columns_hash = all_columns.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |current, res|
          res[current.name] = current
        end
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

        self.columns += [ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, cast_type, mapped_sql_type, null)]

        reset_column_information
      end

      # Do not reset @columns
      def reset_column_information # :nodoc:
        generated_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @generated_methods = nil
      end

      def generated_methods
        @generated_methods ||= Set.new
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
        if superclass.column_names.include?(attribute)
          superclass.inheritance_class_owner(attribute)
        else
          self
        end
      end
    end
  end
end
