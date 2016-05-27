class AddIsclosedToJourneys < ActiveRecord::Migration
  def change
    add_column :journeys, :is_closed, :boolean, default: false
  end
end
