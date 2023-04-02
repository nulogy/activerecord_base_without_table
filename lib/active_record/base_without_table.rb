# frozen_string_literal: true

require "active_record/attributes_builder_without_table"
require "active_record/connection_adapters/null_adapter"
require "active_record/connection_adapters/null_schema_cache"

module ActiveRecord
  # Get the power of ActiveRecord models, including validation, without having a
  # table in the database.
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
  # This model can be used just like a regular model based on a table, except it
  # will never be saved to the database.
  #
  class BaseWithoutTable < Base
    self.abstract_class = true

    class << self
      def connection
        ConnectionAdapters::NullAdapter.new(super)
      end

      def attributes_builder
        AttributesBuilderWithoutTable.new(super)
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

      def column(name, sql_type, default = nil)
        define_attribute(name.to_s, ActiveRecord::Type.lookup(sql_type), default: default)
      end

      def gettext_translation_for_attribute_name(attribute)
        # `rake gettext:store_model_attributes` processes our BaseWithoutTable models, but we have our own rake task
        # for that. Return right away if calling gettext_translation_for_attribute_name on BaseWithoutTable
        return "BaseWithoutTable" if self == BaseWithoutTable

        attribute = attribute.to_s
        if attribute.ends_with?("_id")
          humanize_class_name(attribute)
        else
          "#{self}|#{attribute.split('.').map!(&:humanize).join('|')}"
        end
      end
    end
  end
end
