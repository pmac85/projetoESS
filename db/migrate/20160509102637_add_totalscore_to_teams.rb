class AddTotalscoreToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :total_score, :integer, default: 0
  end
end
