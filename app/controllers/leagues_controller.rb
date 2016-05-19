class LeaguesController < ApplicationController
  require 'round_robin_tournament'
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
    @journeys=@league.journeys
    @teams=Team.find_by_league_id(@league.id)
    p(@teams)
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
    populate_with_journeys
    populate_journeys
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

  def populate_with_journeys
    38.times do |n|
      @journey = Journey.create!(date: (@league.initial_date + n.days), number: (n+1), league_id: @league.id)
    end
  end

  def populate_journeys
    teams = @league.teams.ids
    teams2= teams.map(&:to_s)
    journeys = @league.journeys
    # gera calendario de jogos
    journeys_schedule = RoundRobinTournament.schedule(teams2)

    # atribuo o calendario gerado às jornadas e crio jogos
    journeys_schedule.each_with_index do |day, index|
      journey = journeys.find_by(number: (index + 1))
      day.map { |team| Game.create!(journey_id: journey.id, team1_id: team.first.to_i, team2_id: team.last.to_i)}
    end
  end

end
