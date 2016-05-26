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
    end
    flash[:notice] = "Journey #{journey.number} closed."
    redirect_to league_path(journey.league_id)
  end
end
