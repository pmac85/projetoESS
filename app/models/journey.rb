class Journey < ActiveRecord::Base
  belongs_to :league
  has_many :games
  validates :date,   presence: true
  validates :number, presence: true

  def close_journey_automatic
    if date == Date.today
        self.games.each do |game|
          game.gerarResultado
        end
        self.is_closed = true
        self.save
    end
  end
end
