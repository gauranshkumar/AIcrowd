class AddStartDateToBlitzPuzzle < ActiveRecord::Migration[5.2]
  def change
    add_column :blitz_puzzles, :start_date, :timestamp
  end
end
