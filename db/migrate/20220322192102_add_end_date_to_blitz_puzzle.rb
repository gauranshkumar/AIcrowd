class AddEndDateToBlitzPuzzle < ActiveRecord::Migration[5.2]
  def change
    add_column :blitz_puzzles, :end_date, :timestamp
  end
end
