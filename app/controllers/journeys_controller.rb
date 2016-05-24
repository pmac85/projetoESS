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
end
