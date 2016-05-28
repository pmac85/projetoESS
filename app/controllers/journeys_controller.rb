class JourneysController < ApplicationController

  def index
    @league=League.find(params[:id])
    @journeys=@league.journeys.includes(:games)
    @teams=@league.teams
  end

  def close
    journey=Journey.find(params[:id])
    i = journey.id - 1
    previousj = Journey.find_by_id(i)
    if !journey.is_closed
      if journey.id != 1 && previousj.is_closed
        journey.games.each do |game|
          game.gerarResultado
        end
        journey.is_closed = true
        journey.save
        flash[:info] = "Matchday #{journey.number} closed."
      elsif journey.id == 1
        journey.games.each do |game|
          game.gerarResultado
        end
        journey.is_closed = true
        journey.save
        flash[:info] = "Matchday #{journey.number} closed."
      else
        flash[:warning] = "You can't close one matchday if the previous is open."
      end
    else
      flash[:warning] = "Matchday #{journey.number} can't be closed again."
    end
    redirect_to :back
  end
end
