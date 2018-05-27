require 'spec_helper'
require 'rails_helper'

RSpec.describe ActiveRecord::BaseWithoutTable do
  it 'allows specification of its own attributes' do
    base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :created_at, :datetime
      column :due_on, :date
      column :start_time, :time
      column :external_id, :integer
      column :is_something, :boolean
      column :number, :decimal
      column :description, :text
    end

    instance = base_without_table_class.new(
      created_at: '2019-01-01 00:00:00.000000',
      due_on: '2020-01-01',
      start_time: '00:00:00',
      external_id: '1',
      is_something: 't',
      number: '1.2345678901',
      description: 'My description'
    )

    expect(instance).to have_attributes(
      created_at: Time.zone.parse('2019-01-01T00:00:00Z'),
      due_on: Date.parse('2020-01-01'),
      start_time: Time.zone.parse('2000-01-01T00:00:00Z'),
      external_id: 1,
      is_something: true,
      number: BigDecimal('1.2345678901'),
      description: 'My description'
    )
  end

  it 'allows specification of default values for attributes' do
    base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :number, :integer, 1
    end

    instance = base_without_table_class.new

    expect(instance.number).to eq(1)
  end

  context 'when enforcing validations' do
    it 'can enforce presence of an attribute' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :external_id, :integer

        validates_presence_of :external_id

        def self.name
          'BaseWithoutTableInstance'
        end
      end

      invalid_instance = base_without_table_class.new(external_id: nil)
      valid_instance = base_without_table_class.new(external_id: 2)

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    it 'can enforce inclusion of an attribute in a range of valid values' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :code, :text

        validates_inclusion_of :code, in: ['Code 1', 'Code 2']

        def self.name
          'BaseWithoutTableInstance'
        end
      end

      invalid_instance = base_without_table_class.new(code: 'INVALID')
      valid_instance = base_without_table_class.new(code: 'Code 1')

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    it 'can enforce arbitrary conditions specified by the programmer' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :external_id, :integer

        validate :arbitrary_condition

        def self.name
          'BaseWithoutTableInstance'
        end

        def arbitrary_condition
          return if external_id && external_id.even?
          errors.add(:external_id, 'cannot be odd')
        end
      end

      invalid_instance = base_without_table_class.new(external_id: 1)
      valid_instance = base_without_table_class.new(external_id: 2)

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    it 'can enforce the numericality of attributes' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :external_id, :integer

        validates_numericality_of :external_id

        def self.name
          'BaseWithoutTableInstance'
        end
      end

      invalid_instance = base_without_table_class.new(external_id: "NaN")
      valid_instance = base_without_table_class.new(external_id: "42")

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end

    it 'can enforce the length of an attribute' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :description, :text

        validates_length_of :description, maximum: 3

        def self.name
          'BaseWithoutTableInstance'
        end
      end

      invalid_instance = base_without_table_class.new(description: "1234")
      valid_instance = base_without_table_class.new(description: "123")

      expect(invalid_instance).to_not be_valid
      expect(valid_instance).to be_valid
    end
  end
  
  it 'can be associated to other ActiveRecords' do
    base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :model_id, :integer
      belongs_to :model

      def self.name
        'BaseWithoutTableInstance'
      end
    end
    model = Model.create!(description: 'Something')

    base_without_table = base_without_table_class.new(
      model_id: model.id
    )

    expect(base_without_table.model).to eq(model)
  end

  it 'can be associated to other ActiveRecords by explicitly specifying the associated class name' do
    base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :first_model_id, :integer
      column :second_model_id, :integer
      belongs_to :first_model, class_name: 'Model'
      belongs_to :second_model, class_name: 'Model'

      def self.name
        'BaseWithoutTableInstance'
      end
    end
    first_model = Model.create!(description: 'First model')
    second_model = Model.create!(description: 'Second model')

    base_without_table = base_without_table_class.new(
      first_model_id: first_model.id,
      second_model_id: second_model.id
    )

    expect(base_without_table.first_model).to eq(first_model)
    expect(base_without_table.second_model).to eq(second_model)
  end

  it 'allows construction of records given a SQL statement' do
    base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :model_description, :text

      def self.name
        'BaseWithoutTableInstance'
      end
    end
    Model.create!(description: 'Something')

    base_without_table = base_without_table_class.find_by_sql(<<-SQL)
    SELECT description AS model_description FROM models
    SQL

    expect(base_without_table.first.model_description).to eq('Something')
  end

  it 'generates predicates for boolean columns' do
    base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :is_something, :boolean

      def self.name
        'BaseWithoutTableInstance'
      end
    end

    base_without_table = base_without_table_class.new(is_something: true)

    expect(base_without_table.is_something?).to be(true)
  end

  context 'when using ActiveRecord callbacks' do
    it 'can use after_initialize' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :user_set, :text
        column :automatically_set, :text

        after_initialize :automatically_set_attributes

        def self.name
          'BaseWithoutTableInstance'
        end

        def automatically_set_attributes
          self.automatically_set = 'Automatic'
        end
      end

      base_without_table = base_without_table_class.new(user_set: 'Value')

      expect(base_without_table.automatically_set).to eq('Automatic')
    end

    it 'can use before_validation' do
      base_without_table_class = Class.new(ActiveRecord::BaseWithoutTable) do
        column :number, :decimal

        before_validation :default_number_to_0
        validates_numericality_of :number

        def self.name
          'BaseWithoutTableInstance'
        end

        def default_number_to_0
          return if number
          self.number = 0
        end
      end

      base_without_table = base_without_table_class.new

      expect(base_without_table).to be_valid
      expect(base_without_table.number).to eq(0)
    end
  end
end
