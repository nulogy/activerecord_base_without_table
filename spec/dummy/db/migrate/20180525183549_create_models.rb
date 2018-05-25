class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.timestamps

      t.text :description
    end
  end
end
