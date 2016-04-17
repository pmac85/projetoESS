class Team < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :league
  has_many    :players
  validates   :user_id,   presence: true
  validates   :league_id, presence: true
  validates   :name,      presence: true, length: { maximum: 40 }
end
