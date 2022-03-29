class TypeChangeOfBlitzCategory < ActiveRecord::Migration[5.2]
  def change
    change_column :blitz_puzzles, :blitz_category_id, :integer, using: 'blitz_category_id::integer'
  end
end
