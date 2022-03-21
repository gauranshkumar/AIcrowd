class CreateActivityMeta < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_meta do |t|
      t.integer :participant_id
      t.string :type
      t.integer :acted_on
    end
  end
end
