class AddPointsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :coach_points, :integer, default: 0
  end
end
