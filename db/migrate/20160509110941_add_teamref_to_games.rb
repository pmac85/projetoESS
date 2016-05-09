class AddTeamrefToGames < ActiveRecord::Migration
  def change
    add_column :games, :team1_id, :integer, foreign_key: true
    add_column :games, :team2_id, :integer, foreign_key: true
  end
end
