class Season < ActiveRecord::Base
  has_many :journeys
  has_and_belongs_to_many :leagues
  validates :number, presence: true
end
