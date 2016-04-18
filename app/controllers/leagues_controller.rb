class LeaguesController < ApplicationController

  def show
    @league = League.find(params[:id])
  end

  def index
    @leagues = League.paginate(page: params[:page])
  end
end
