class ChangeTypeToEvent < ActiveRecord::Migration[5.2]
  def change
    rename_column :activity_meta, :type, :event
  end
end
