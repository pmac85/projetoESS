class AddJourneyIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :journey_id, :integer
  end
end
