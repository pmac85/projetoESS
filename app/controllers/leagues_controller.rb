class LeaguesController < ApplicationController
  require 'round_robin_tournament'
  before_action :check_league,   except: [:new, :create, :destroy ]
  before_action :admin_user,     only: [:new, :create, :destroy]

  def show
    @league = League.find(params[:id])
    @teams = @league.teams.all.includes(:user).order(:total_score)
  end

  def index
    @leagues = League.paginate(page: params[:page])
  end

  def new
    @league = League.new
  end

  def create
    if current_user.admin
      @league = League.new(league_params)
      if @league.save
        populate_league(@league)
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

  def destroy
    @league = League.find(params[:id])
    @league.teams.each do |team|
      team.players.update_all(team_id: nil, is_chosen: false, is_active: false)
      team.destroy
    end
    @league.destroy
    flash[:success] = "League deleted. You can create a new League now!"
    redirect_to new_league_path
  end

  private
  def league_params
    params.require(:league).permit(:name, :initial_date)
  end

  def check_league
    if !League.any?
      league = League.new
      league.update_attributes(name: "Liga NOS", initial_date: Date.today + 7.days)
      league.save
      populate_league(league)
    end
  end

  def populate_league(league)
    20.times do |n|
      Team.create!(name: "Team#{n+1}", user_id: nil, league_id: league.id, budget: 900)
    end
    populate_teams(league)
    populate_with_journeys(league)
    populate_journeys(league)
  end

  def populate_teams(league)
    @allplayers = Player.where( "value < ?", 61).where(is_chosen: false)
    league.teams.each do |team|
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

  def populate_with_journeys(league)
    38.times do |n|
      @journey = Journey.create!(date: (league.initial_date + n.days), number: (n+1), league_id: league.id)
    end
  end

  def populate_journeys(league)
    teams = league.teams.ids
    teams2= teams.map(&:to_s)
    journeys = league.journeys
    # gera calendario de jogos
    journeys_schedule = RoundRobinTournament.schedule(teams2)

    # atribuo o calendario gerado às jornadas e crio jogos
    journeys_schedule.each_with_index do |day, index|
      journey = journeys.find_by(number: (index + 1))
      day.map { |team| Game.create!(journey_id: journey.id, team1_id: team.first.to_i, team2_id: team.last.to_i)}
      day.map { |team| Game.create!(journey_id: (journey.id+19), team1_id: team.last.to_i, team2_id: team.first.to_i)}
    end
  end

end
