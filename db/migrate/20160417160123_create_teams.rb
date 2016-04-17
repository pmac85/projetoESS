class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :budget
      t.references :user, index: true, foreign_key: true
      t.references :league, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
