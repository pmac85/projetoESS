class Team < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :league
  has_many    :players
  validates   :league_id, presence: true
  validates   :name,      presence: true, length: { maximum: 40 }
  validate :oneTeamPerUserPerLeague
  validate :actives

  private
  def oneTeamPerUserPerLeague
    return if(self.user_id == nil)
    @teams = Team.where(user_id: self.user_id, league_id: self.league_id)
    errors.add(:user_id, 'Error in Team, you can only have one team per user per league') if(@teams.size > 1)
  end

  def actives
    aplayers = self.players.where(is_active: true).count
    if aplayers == 0
      gk = self.players.where(position: "GK").limit(1)
      gk.update_all(is_active: true)
      defense = self.players.where(position: "DEF").limit(4)
      defense.update_all(is_active: true)
      mid = self.players.where(position: "MID").limit(4)
      mid.update_all(is_active: true)
      forward = self.players.where(position: "FOR").limit(2)
      forward.update_all(is_active: true)
    end
  end
end
