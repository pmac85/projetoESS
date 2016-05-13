class LeaguesController < ApplicationController
  before_action :admin_user,     only: [:new, :create]

  def show
    @league = League.find(params[:id])
    @teams = @league.teams.all
  end

  def index
    @leagues = League.all
  end

  def new
    @league = League.new
  end

  def create
    if current_user.admin
      @league = League.new(league_params)
      if @league.save
        flash[:success] = "League successfully created"
        redirect_to league_path(@league)
      else
        flash[:warning] = "Something is missing."
        render 'new'
      end
    else
      flash[:warning] = "You don't have authorization to create a league!"
      redirect_to root_path
    end
  end

  private
  def league_params
    params.require(:league).permit(:name, :initial_date)
  end
end
