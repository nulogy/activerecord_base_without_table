require 'spec_helper'
require 'rails_helper'

RSpec.describe ActiveRecord::BaseWithoutTable do
  it "allows specification of its own attributes" do
    model_class = Class.new(ActiveRecord::BaseWithoutTable) do
      column :created_at, :datetime
      column :due_on, :date
      column :start_time, :time
      column :external_id, :integer
      column :is_something, :boolean
      column :number, :decimal
      column :description, :text
    end

    instance = model_class.new(
      created_at: "2019-01-01 00:00:00.000000",
      due_on: "2020-01-01",
      start_time: "00:00:00",
      external_id: "1",
      is_something: "t",
      number: "1.2345678901",
      description: "My description"
    )

    expect(instance).to have_attributes(
      created_at: Time.zone.parse("2019-01-01T00:00:00Z"),
      due_on: Date.parse("2020-01-01"),
      start_time: Time.zone.parse("2000-01-01T00:00:00Z"),
      external_id: 1,
      is_something: true,
      number: BigDecimal.new("1.2345678901"),
      description: "My description"
    )
  end
end
