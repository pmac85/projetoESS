class Player < ActiveRecord::Base
  belongs_to :team
  validates :name,      presence: true
  validates :position,  presence: true
  validates :value,     presence: true
  validate :validate_number_in_team, :playersPositions


  private
  def validate_number_in_team
      errors.add(:team_id, "Error in team_id, team can't have more than 15 players") if(team_id && Player.where(team_id: self.team_id).size >= 15)
  end
  def playersPositions
    return if !self.team_id
    size = Player.where(team_id: self.team_id, position: self.position).size

    case self.position
      when 'GK'
        errors.add(:position, 'Error in Player, there are already too many players with this position') if(size > 2)
      when 'DEF'
        errors.add(:position, 'Error in Player, there are already too many players with this position') if(size > 5)
      when 'MID'
        errors.add(:position, 'Error in Player, there are already too many players with this position') if(size > 5)
      when 'FOR'
        errors.add(:position, 'Error in Player, there are already too many players with this position') if(size > 3)
    end
  end
end
