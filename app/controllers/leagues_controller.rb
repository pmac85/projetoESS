class LeaguesController < ApplicationController
  require 'round_robin_tournament'
  before_action :check_league,   except: [:new, :create, :destroy, :index ]
  before_action :admin_user,     only: [:new, :create, :destroy]

  def show
    @league = League.find(params[:id])
    @teams = @league.teams.all.order('total_score DESC, goals_scored DESC, goals_suffered ASC')
    journeys=@league.journeys
    index=-1
    index2=0
    nextt=""
    nextid=""
    nextj=""
    lastj1=""
    last=""
    lastj2=""
    lastid1=""
    lastid2=""
    usrt=current_user.teams.where(league_id:@league.id).first()
    if(usrt!=nil)
    usrtid=usrt.id
    journeys.each do |journey|
      if(!journey.is_closed)
          index2=index
          break
          end
        index=index+1
    end
      if(index2==-1)
        g= journeys.first.games
        g.each do |game|
          if(game.team1_id==usrtid)
            nextt="Next Oponent: "
            nextid=game.team2_id.to_s
            nextj=game.team2.name
            break
          end
          if(game.team2_id==usrtid)
            nextt="Next Oponent: "
            nextid=game.team1_id.to_s
            nextj=game.team1.name
            break
          end
        end
      else
        index2=index2+1
        g= journeys.find(index2).games
        g.each do |game|
          if(game.team1_id==usrtid || game.team2_id==usrtid)
            lastid1=game.team1_id.to_s
            lastj1=game.team1.name
            last=game.team1_score.to_s + " - " + game.team2_score.to_s
            lastid2=game.team2_id.to_s
            lastj2=game.team2.name
            break
          end
        end
        index2=index2+1
        if(index2<=journeys.length)
        g= journeys.find(index2).games
        g.each do |game|
          if(game.team1_id==usrtid)
            nextt="Next Oponent: "
            nextid=game.team2_id.to_s
            nextj=game.team2.name
            break
          end
          if(game.team2_id==usrtid)
            nextt="Next Oponent: "
            nextid=game.team1_id.to_s
            nextj=game.team1.name
            break
          end
        end
      end
    end
      end
    @next=nextt
    @nextid=nextid
    @nextj=nextj
    @lastj1=lastj1
    @lastj2=lastj2
    @lastid1=lastid1
    @lastid2=lastid2
    @last=last
  end

  def index
    if League.any?
      @leagues = League.paginate(page: params[:page])
    elsif current_user.admin
      flash[:info] = "There is any league created. Please create one!"
      redirect_to new_league_path
    else
      flash[:info] = "There is any league created."
      redirect_to user_path(current_user.id)
    end
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
        render 'new'
      end
    else
      flash[:warning] = "You don't have authorization to create a league!"
      redirect_to root_path
    end
  end

  def destroy
    @league = League.find(params[:id])
    if @league.journeys.last.is_closed
      array = League.find(params[:id]).teams.all.order('total_score ASC')
      @league.teams.each do |team|
        if(team.user_id != nil)
          user = User.find(team.user_id)
          p(user)
          user.coach_points += array.index(team) + 1
          user.save
        end
        team.players.update_all(team_id: nil, is_chosen: false, is_active: false)
        team.destroy
      end
      @league.journeys.each do |journey|
        journey.games.each do |game|
          game.destroy
        end
        journey.destroy
      end
      @league.destroy
      flash[:success] = "League deleted. You can create a new League now!"
      redirect_to new_league_path
    else
      flash[:warning] = "You can not destroy a league that isn't over yet!"
      redirect_to :back
    end
  end

  def close_all
    league = League.find(params[:id])

    league.journeys.each do |journey|
      if(!journey.is_closed)
        journey.games.each do |game|
          game.gerarResultado
        end
        journey.is_closed = true
        journey.save
      end
    end

    redirect_to :back
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
    @allplayers = Player.where( "value < ?", 65).where(is_chosen: false)
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
