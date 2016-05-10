class AddIsactiveToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :is_active, :boolean, default: false
  end
end
