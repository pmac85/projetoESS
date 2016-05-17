class AddLeagueIdToJourney < ActiveRecord::Migration
  def change
    add_column :journeys, :league_id, :integer
  end
end
