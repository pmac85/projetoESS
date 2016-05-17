class JourneysController < ApplicationController

  def new
    @journey = Journey.new
  end

  def create
    params[:journeys].inspect
    render nothing: true
  end
end
