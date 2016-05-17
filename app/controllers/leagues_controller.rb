class LeaguesController < ApplicationController
  before_action :admin_user,     only: [:new, :create]

  def show
    @league = League.find(params[:id])
    @teams = @league.teams.all
  end

  def index
    @leagues = League.paginate(page: params[:page])
    #@leagues = League.all
  end

  def new
    @league = League.new
  end

  def create
    if current_user.admin
      @league = League.new(league_params)
      if @league.save
        populate_league
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
  def calendarshow
    @league=League.find(1)
    p(@league)
    @journeys=@league.journeys.paginate(page: params[:page],:per_page=>1)
    p(@journeys)
  end
  private
  def league_params
    params.require(:league).permit(:name, :initial_date)
  end

  def populate_league
    20.times do |n|
      Team.create!(name: "Team#{n+1}", user_id: nil, league_id: @league.id, budget: 900)
    end
    populate_teams
  end

  def populate_teams
    @allplayers = Player.where(is_chosen: false).includes(:team)
    @league.teams.each do |team|
      @gk = @allplayers.where(is_chosen: false, position: "GK").sample(2)
      @def = @allplayers.where(is_chosen: false, position: "DEF").sample(5)
      @mid = @allplayers.where(is_chosen: false, position: "MID").sample(5)
      @for = @allplayers.where(is_chosen: false, position: "FOR").sample(3)
      @budget = team.budget

      @gk.each do |gk|
        gk.update_attributes(team_id: team.id, is_chosen: true)
        @budget -= gk.value
      end
      @def.each do |defense|
        defense.update_attributes( team_id: team.id, is_chosen: true)
        @budget -= defense.value
      end
      @mid.each do |mid|
        mid.update_attributes( team_id: team.id, is_chosen: true)
        @budget -= mid.value
      end
      @for.each do |forward|
        forward.update_attributes( team_id: team.id, is_chosen: true)
        @budget -= forward.value
      end
      team.update_attributes(budget: @budget)
    end
  end


end
