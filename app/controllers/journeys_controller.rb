class JourneysController < ApplicationController

  def new
    @journey = Journey.new
  end

  def create
    params[:journeys].inspect
    render nothing: true
  end

  def index
    @league=League.find(params[:id])
    @journeys=@league.journeys.includes(:games)
    @teams=@league.teams
  end

  def close
    journey=Journey.find(params[:id])
    journey.games.each do |game|
      game.gerarResultado
      case game
        when (game.team1_score - team2_score) > 0
          Team.find(game.team1_id).update_all(total_score: total_score+3, victories: victories+1)
          Team.find(game.team2_id).update_all(defeats: defeats+1)
        when (game.team1_score - team2_score) < 0
          Team.find(game.team2_id).update_all(total_score: total_score+3, victories: victories+1)
          Team.find(game.team1_id).update_all(defeats: defeats+1)
        when (game.team1_score - team2_score) == 0
          Team.find(game.team1_id).update_all(total_score: total_score+1, draws: draws+1)
          Team.find(game.team2_id).update_all(total_score: total_score+1, draws: draws+1)
      end
    end
  end
end
