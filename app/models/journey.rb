class Journey < ActiveRecord::Base
  belongs_to :league
  has_many :game
  validates :date,   presence: true
  validates :number, presence: true
end
