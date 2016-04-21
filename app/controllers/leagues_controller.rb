class LeaguesController < ApplicationController

  def show
    @league = League.find(params[:id])
    @teams = @league.teams.paginate(page: params[:page])
  end

  def index
    @leagues = League.paginate(page: params[:page])
  end
end
