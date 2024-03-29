require "spec_helper"
require "rails_helper"

RSpec.describe ActiveRecord::BaseWithoutTable do
  context "when specifying columns" do
    it "allows specification of its own attributes" do
      base_without_table_class = sample_model do
        column :description, :text
        column :due_on, :date
        column :external_id, :integer
        column :is_something, :boolean
        column :number, :decimal
        column :signed_at, :datetime
        column :start_time, :time
      end

      instance = base_without_table_class.new(
        description: "My description",
        due_on: "2020-01-01",
        external_id: "1",
        is_something: "t",
        number: "1.2345678901",
        signed_at: "2019-01-01 00:30:00.000000",
        start_time: "00:00:20"
      )

      # Explicitly validate the application.rb configuration for the dummy app.
      aggregate_failures do
        expect(Time.zone.name).to eq("Eastern Time (US & Canada)")
        expect(ActiveRecord::Base.time_zone_aware_types).to_not include(:time)
      end

      # Explicitly validate that the spec is running during Eastern Daylight Time.
      # If not, the offsets from UTC will have to be adjusted by an hour.
      expect(Time.zone.now.zone).to eq("EDT")

      expect(instance).to have_attributes(
        description: "My description",
        due_on: Date.parse("2020-01-01"),
        external_id: 1,
        is_something: true,
        number: BigDecimal("1.2345678901"),

        # Datetime columns in Rails are stored in UTC and understand timezone offsets.
        signed_at: Time.zone.parse("2019-01-01T05:30:00Z"),

        # Time columns in Rails have a dummy date of January 1st 2000 attached to them and are stored in UTC.
        start_time: Time.utc(2000, 1, 1, 0, 0, 20)
      )
    end

    it "allows specification of default values for attributes" do
      base_without_table_class = sample_model do
        column :number, :integer, 1
      end

      instance = base_without_table_class.new

      expect(instance.number).to eq(1)
    end

    it "generates predicates for boolean columns" do
      base_without_table_class = sample_model do
        column :is_something, :boolean

        def self.name
          "BaseWithoutTableInstance"
        end
      end

      base_without_table = base_without_table_class.new(is_something: true)

      expect(base_without_table.is_something?).to be(true)
    end
  end

  context "when enforcing validations" do
    it "can enforce presence of an attribute" do
      base_without_table_class = sample_model do
        column :external_id, :integer

        validates_presence_of :external_id

        def self.name
          "BaseWithoutTableInstance"
        end
      end

      invalid_instance = base_without_table_class.new(external_id: nil)
      valid_instance = base_without_table_class.new(external_id: 2)

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    it "can enforce inclusion of an attribute in a range of valid values" do
      base_without_table_class = sample_model do
        column :code, :text

        validates_inclusion_of :code, in: ["Code 1", "Code 2"]

        def self.name
          "BaseWithoutTableInstance"
        end
      end

      invalid_instance = base_without_table_class.new(code: "INVALID")
      valid_instance = base_without_table_class.new(code: "Code 1")

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    it "can enforce arbitrary conditions specified by the programmer" do
      base_without_table_class = sample_model do
        column :external_id, :integer

        validate :arbitrary_condition

        def self.name
          "BaseWithoutTableInstance"
        end

        def arbitrary_condition
          return if external_id&.even?

          errors.add(:external_id, "cannot be odd")
        end
      end

      invalid_instance = base_without_table_class.new(external_id: 1)
      valid_instance = base_without_table_class.new(external_id: 2)

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    context "when validating numericality" do
      it "can enforce the numericality of attributes" do
        base_without_table_class = sample_model do
          column :external_id, :integer

          validates_numericality_of :external_id

          def self.name
            "BaseWithoutTableInstance"
          end
        end

        invalid_instance = base_without_table_class.new(external_id: "NaN")
        valid_instance = base_without_table_class.new(external_id: "42")

        expect(invalid_instance).to_not be_valid
        expect(valid_instance).to be_valid
      end

      it "can enforce numericality of multiple attributes" do
        base_without_table_class = sample_model do
          column :first_attribute, :integer
          column :second_attribute, :integer

          validates_numericality_of :first_attribute, :second_attribute

          def self.name
            "BaseWithoutTableInstance"
          end
        end

        invalid_instance = base_without_table_class.new(first_attribute: "foo", second_attribute: "2")
        valid_instance = base_without_table_class.new(first_attribute: "1", second_attribute: "2")

        expect(invalid_instance).to_not be_valid
        expect(valid_instance).to be_valid
      end

      it "can require an attribute to be greater than or equal to a given value" do
        base_without_table_class = sample_model do
          column :first_attribute, :integer

          validates_numericality_of :first_attribute, greater_than_or_equal_to: 10

          def self.name
            "BaseWithoutTableInstance"
          end
        end

        invalid_instance = base_without_table_class.new(first_attribute: "9")
        valid_instance = base_without_table_class.new(first_attribute: "11")

        expect(invalid_instance).to_not be_valid
        expect(valid_instance).to be_valid
      end
    end

    context "when validating length" do
      it "can enforce the length of an attribute" do
        base_without_table_class = sample_model do
          column :description, :text

          validates_length_of :description, maximum: 3

          def self.name
            "BaseWithoutTableInstance"
          end
        end

        invalid_instance = base_without_table_class.new(description: "1234")
        valid_instance = base_without_table_class.new(description: "123")

        expect(invalid_instance).to_not be_valid
        expect(valid_instance).to be_valid
      end

      it "can be configured to allow nil text attributes" do
        base_without_table_class = sample_model do
          column :description, :text

          validates_length_of :description, maximum: 3, allow_nil: true

          def self.name
            "BaseWithoutTableInstance"
          end
        end

        valid_instance = base_without_table_class.new(description: nil)

        expect(valid_instance).to be_valid
      end
    end
  end

  context "when specifying associations" do
    it "can be associated to other ActiveRecords" do
      base_without_table_class = sample_model do
        column :model_id, :integer
        belongs_to :model

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      model = Model.create!(description: "Something")

      base_without_table = base_without_table_class.new(
        model_id: model.id
      )

      expect(base_without_table.model).to eq(model)
    end

    it "can be associated to other ActiveRecords by explicitly specifying the associated class name" do
      base_without_table_class = sample_model do
        column :first_model_id, :integer
        column :second_model_id, :integer
        belongs_to :first_model, class_name: "Model"
        belongs_to :second_model, class_name: "Model"

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      first_model = Model.create!(description: "First model")
      second_model = Model.create!(description: "Second model")

      base_without_table = base_without_table_class.new(
        first_model_id: first_model.id,
        second_model_id: second_model.id
      )

      expect(base_without_table.first_model).to eq(first_model)
      expect(base_without_table.second_model).to eq(second_model)
    end

    it "can be associated to other ActiveRecords by explicitly specifying the foreign key attribute" do
      base_without_table_class = sample_model do
        column :my_model_id, :integer
        belongs_to :model, foreign_key: "my_model_id"

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      model = Model.create!(description: "First model")

      base_without_table = base_without_table_class.new(my_model_id: model.id)

      expect(base_without_table.model).to eq(model)
    end
  end

  context "when using ActiveRecord callbacks" do
    it "can use after_initialize" do
      base_without_table_class = sample_model do
        column :user_set, :text
        column :automatically_set, :text

        after_initialize :automatically_set_attributes

        def self.name
          "BaseWithoutTableInstance"
        end

        def automatically_set_attributes
          self.automatically_set = "Automatic"
        end
      end

      base_without_table = base_without_table_class.new(user_set: "Value")

      expect(base_without_table.automatically_set).to eq("Automatic")
    end

    it "can use before_validation" do
      base_without_table_class = sample_model do
        column :number, :decimal

        before_validation :default_number_to_zero
        validates_numericality_of :number

        def self.name
          "BaseWithoutTableInstance"
        end

        def default_number_to_zero
          return if number

          self.number = 0
        end
      end

      base_without_table = base_without_table_class.new

      expect(base_without_table).to be_valid
      expect(base_without_table.number).to eq(0)
    end
  end

  context "when executing queries" do
    it "allows construction of records given a SQL statement" do
      base_without_table_class = sample_model do
        column :model_description, :text

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      Model.create!(description: "Something")

      matching_records = base_without_table_class.find_by_sql(<<-SQL)
    SELECT description AS model_description FROM models
      SQL

      expect(matching_records.first.model_description).to eq("Something")
    end

    it "supports specification of named SQL bindings" do
      base_without_table_class = sample_model do
        column :model_description, :text

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      Model.create!(description: "Find me")
      Model.create!(description: "Ignore me")

      matching_records = base_without_table_class.find_by_sql([<<-SQL, { description: "Find me" }])
    SELECT description AS model_description FROM models WHERE description LIKE :description
      SQL

      expect(matching_records.length).to eq(1)
      expect(matching_records.first.model_description).to eq("Find me")
    end

    it "supports specification of positional SQL bindings" do
      base_without_table_class = sample_model do
        column :model_description, :text

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      Model.create!(description: "Find me")
      Model.create!(description: "Ignore me")

      matching_records = base_without_table_class.find_by_sql([<<-SQL, "Find me"])
    SELECT description AS model_description FROM models WHERE description LIKE ?
      SQL

      expect(matching_records.length).to eq(1)
      expect(matching_records.first.model_description).to eq("Find me")
    end

    it "converts datetime columns to the `Time.zone`" do
      base_without_table_class = sample_model do
        column :created_at, :datetime

        def self.name
          "BaseWithoutTableInstance"
        end
      end
      Model.create!

      matching_records = base_without_table_class.find_by_sql(<<-SQL)
    SELECT created_at FROM models
      SQL

      expect(matching_records.first.created_at.time_zone).to eq(Time.zone)
    end
  end

  context "when generating translations" do
    module BaseWithoutTableTests # rubocop:disable Lint/ConstantDefinitionInBlock
      class Person < ActiveRecord::BaseWithoutTable
        column :name, :text
        column :lucky_number, :integer, 4

        validates_presence_of :name
      end
    end

    it "supports gettext translations for attribute names" do
      translation = BaseWithoutTableTests::Person.gettext_translation_for_attribute_name(:name)

      expect(translation).to eq("BaseWithoutTableTests::Person|Name")
    end
  end

  context "when registering custom types" do
    before do
      module ActiveRecord # rubocop:disable Lint/ConstantDefinitionInBlock
        module Type
          class DateTimePoint < DateTime
            def type
              :datetime_point
            end
          end
        end
      end

      ActiveRecord::Type.register(:datetime_point, ActiveRecord::Type::DateTimePoint, override: false)
    end

    it "supports the datetime_point custom type" do
      expect do
        sample_model do
          column :snapshot_at, :datetime_point
        end
      end.to_not raise_error
    end
  end

  def sample_model(&block)
    Class.new(described_class, &block)
  end
end
