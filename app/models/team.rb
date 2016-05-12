class Team < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :league
  has_many    :players
  validates   :user_id,   presence: true
  validates   :league_id, presence: true
  validates   :name,      presence: true, length: { maximum: 40 }
  validate :oneTeamPerUserPerLeague

  private
  def oneTeamPerUserPerLeague
    return if(self.user_id == nil)
    @teams = Team.where(user_id: self.user_id, league_id: self.league_id)
    errors.add(:user_id, 'Error in Team, you can only have one team per user per league') if(@teams.size > 1)
  end
end
