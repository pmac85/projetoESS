class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :position
      t.integer :value
      t.references :team, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
