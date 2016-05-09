class League < ActiveRecord::Base
  has_many :teams
  has_many :seasons
  validates :name, presence:  true
end
