class Journey < ActiveRecord::Base
  belongs_to :league
  has_many :games
  validates :date,   presence: true
  validates :number, presence: true

end
