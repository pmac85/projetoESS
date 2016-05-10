class AddIsChosenToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :is_chosen, :boolean, default: false
  end
end
