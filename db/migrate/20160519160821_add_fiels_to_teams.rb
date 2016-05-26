class AddFielsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :victories, :integer, default: 0
    add_column :teams, :draws, :integer, default: 0
    add_column :teams, :defeats, :integer, default: 0
  end
end
