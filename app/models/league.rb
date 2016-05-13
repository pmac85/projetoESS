class League < ActiveRecord::Base
  has_many :teams
  has_many :journeys
  validates :name, presence:  true
  validates :initial_date, presence: true
end
