class AddDurationToBlitzPuzzle < ActiveRecord::Migration[5.2]
  def change
    add_column :blitz_puzzles, :duration, :int, default: 7
  end
end
