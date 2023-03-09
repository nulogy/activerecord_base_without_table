class CreateModels < ActiveRecord::Migration[7.0]
  def change
    create_table :models do |t|
      t.timestamps

      t.text :description
    end
  end
end
