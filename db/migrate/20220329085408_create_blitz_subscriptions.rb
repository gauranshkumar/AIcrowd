class CreateBlitzSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :blitz_subscriptions do |t|
      t.integer :participant_id
      t.timestamp :start_date
      t.timestamp :end_date
      t.string :source

      t.timestamps
    end
  end
end
