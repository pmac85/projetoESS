class Game < ActiveRecord::Base
  belongs_to :journey
  belongs_to :team1, foreign_key: 'team1_id', class_name: 'Team'
  belongs_to :team2, foreign_key: 'team2_id', class_name: 'Team'
end
