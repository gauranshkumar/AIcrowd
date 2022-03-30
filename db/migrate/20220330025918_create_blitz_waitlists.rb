class CreateBlitzWaitlists < ActiveRecord::Migration[5.2]
  def change
    create_table :blitz_waitlists do |t|
      t.integer :participant_id
      t.string :email

      t.timestamps
    end
  end
end
