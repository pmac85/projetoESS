class CreateRealTeams < ActiveRecord::Migration
  def change
    create_table :real_teams do |t|
      t.string :name
      t.string :image_path

      t.timestamps null: false
    end
  end
end
