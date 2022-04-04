class CreateBlitzCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :blitz_categories do |t|
      t.string :name
      t.string :icon

      t.timestamps
    end
  end
end