class JourneysController < ApplicationController

  def index
    @league=League.find(params[:id])
    @journeys=@league.journeys.includes(:games)
    @teams=@league.teams
  end

  def close
    journey=Journey.find(params[:id])
    if !journey.is_closed
      journey.games.each do |game|
        game.gerarResultado
      end
      journey.is_closed = true
      journey.save
      flash[:notice] = "Journey #{journey.number} closed."
      redirect_to :back
    else
      flash[:info] = "Journey #{journey.number} can't be closed again."
    end
  end
end
