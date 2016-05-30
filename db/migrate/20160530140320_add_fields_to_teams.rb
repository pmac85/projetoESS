class AddFieldsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :goals_scored, :integer, default: 0
    add_column :teams, :goals_suffered, :integer, default: 0
  end
end
