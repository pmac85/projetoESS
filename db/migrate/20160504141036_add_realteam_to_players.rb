class AddRealteamToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :real_team, :string
  end
end
