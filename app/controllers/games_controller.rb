class GamesController < ApplicationController

  def show
    @game=Game.find(params[:id])
    @team1=Team.find(@game.team1_id)
    @team2=Team.find(@game.team2_id)
  end
end
