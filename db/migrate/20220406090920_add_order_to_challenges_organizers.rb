class AddOrderToChallengesOrganizers < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges_organizers, :order, :integer, :default => 0
  end
end
