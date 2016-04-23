class Player < ActiveRecord::Base
  belongs_to :team
  validates :name,      presence: true
  validates :position,  presence: true
  validates :value,     presence: true
  validate :validate_number_in_team


  private
  def validate_number_in_team
    if team_id && Player.where(team_id: team_id).size >= 15
        errors.add(:team_id, "Error in team_id, team can't have more than 15 players")
        return false
    end

    return true
  end
end
