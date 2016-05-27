class Journey < ActiveRecord::Base
  belongs_to :league
  has_many :games
  validates :date,   presence: true
  validates :number, presence: true
  validate 'close_journey_automatic'

  def close_journey_automatic
    case date
      when date == Date.today.end_of_day
        self.games.each do |game|
          game.gerarResultado
        end
        self.is_closed = true
        self.save
    end
  end
end
