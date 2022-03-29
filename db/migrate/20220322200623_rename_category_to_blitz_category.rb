class RenameCategoryToBlitzCategory < ActiveRecord::Migration[5.2]
  def change
    rename_column :blitz_puzzles, :category, :blitz_category_id
  end
end
