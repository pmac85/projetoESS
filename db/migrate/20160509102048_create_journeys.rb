class CreateJourneys < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.date :date
      t.integer :number

      t.timestamps null: false
    end
  end
end
