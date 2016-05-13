class AddDateToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :initial_date, :date
  end
end
