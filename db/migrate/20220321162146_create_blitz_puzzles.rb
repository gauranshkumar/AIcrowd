class CreateBlitzPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :blitz_puzzles do |t|
      t.integer :challenge_id, :null => false
      t.string :app_link
      t.string :baseline_link
      t.integer :difficulty, :null => false, :default => 1
      t.string :category
      t.boolean :free, :null => false, :default => true
      t.boolean :trial, :null => false, :default => false

      t.timestamps
    end
  end
end
