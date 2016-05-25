class AddTeamscoresToGames < ActiveRecord::Migration
  def change
    add_column :games, :team1_score, :integer
    add_column :games, :team2_score, :integer
  end
end
