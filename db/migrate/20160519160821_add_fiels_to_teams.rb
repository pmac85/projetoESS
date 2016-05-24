class AddFielsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :victories, :integer
    add_column :teams, :draws, :integer
    add_column :teams, :defeats, :integer
  end
end
