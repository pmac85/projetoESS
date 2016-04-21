class AddIsChosenToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :isChosen, :boolean, default: false
  end
end
