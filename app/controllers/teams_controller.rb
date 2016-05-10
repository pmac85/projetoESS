class TeamsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :edit]
  before_action :correct_user

  def index
    if(current_user.admin)
      @teams = Team.paginate(page: params[:page])
    else
      @teams = current_user.teams
    end
  end

  def show
    @team = Team.find(params[:id])
    @players = @team.players
  end

  def edit
    positionFilter = params[:positionFilter]
    valueFilter = params[:valueFilter]
    @team = Team.find(params[:id])
    @players = @team.players
    @allplayers = Player.where(is_chosen: false).includes(:team)
    if (positionFilter == "-1" && valueFilter == "-1")
      @allplayers = Player.where(is_chosen: false).includes(:team)
    elsif (positionFilter != "-1" && valueFilter == "-1")
      case positionFilter
        when "1"
          @allplayers = Player.where(position: "GK", is_chosen: false).includes(:team)
        when "2"
          @allplayers = Player.where(position: "DEF", is_chosen: false).includes(:team)
        when "3"
          @allplayers = Player.where(position: "MID", is_chosen: false).includes(:team)
        when "4"
          @allplayers = Player.where(position: "FOR", is_chosen: false).includes(:team)
      end
    elsif (positionFilter == "-1" && valueFilter != "-1")
      @allplayers = Player.where(value: 0..valueFilter.to_i, is_chosen: false).includes(:team)
    else
      case positionFilter
        when "1"
          @allplayers = Player.where(position: "GK", value: 0..valueFilter.to_i, is_chosen: false).includes(:team)
        when "2"
          @allplayers = Player.where(position: "DEF", value: 0..valueFilter.to_i, is_chosen: false).includes(:team)
        when "3"
          @allplayers = Player.where(position: "MID", value: 0..valueFilter.to_i, is_chosen: false).includes(:team)
        when "4"
          @allplayers = Player.where(position: "FOR", value: 0..valueFilter.to_i, is_chosen: false).includes(:team)
      end
    end
  end

  def transfer
    sell = params[:sell].split(',')
    buy = params[:buy].split(',')

    @team = Team.find(params[:id])
    @allplayers = Player.where(is_chosen: false).includes(:team)
    if sell && buy
      sell.each do |s|
        @player = @team.players.find(s.to_i)
        @player.team_id = nil
        @player.is_chosen = false
        @player.is_active = false
        @player.save
      end
      buy.each do |b|
        @playerb = @allplayers.find(b.to_i)
        @playerb.team_id = @team.id
        @playerb.is_chosen = true
        @playerb.save
      end

      @team.save
      flash[:success] = "Transference successfully realized."
    else
      flash[:error] = "Transferência não pode ser realizada"
    end
    redirect_to edit_team_path(@team)
  end

  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(team_params)
      flash[:success] = "Transference successfully realized."
      redirect_to team(current_user)
    end
  end

  def create
    @team = current_user.teams.build(team_params)
    if @team.save
      flash[:success] = "Team successfully created."
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
    @team = Team.find(params[:id]).destroy
    #flash[:success] = "Team deleted"
    respond_to do |format|
      format.html {redirect_to request.referrer || root_url}
      format.js
    end

  end

  private
  def team_params
    params.require(:team).permit(:name, :image_path)
  end

  def correct_user
    @team = current_user.teams#.find_by(id: params[:id])
    return if(current_user.admin)
    redirect_to root_url if @team.nil?
  end
end
