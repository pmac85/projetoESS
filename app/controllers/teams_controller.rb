class TeamsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :edit]
  before_action :correct_user

  def index
    if(current_user.admin)
      @teams = Team.paginate(page: params[:page])
    else
      @teams = current_user.teams.paginate(page: params[:page])
    end
  end

  def show
    @team = Team.find(params[:id])
    @players = @team.players.paginate(page: params[:page])
  end

  def edit
    positionFilter = params[:positionFilter]
    valueFilter = params[:valueFilter]
    @team = Team.find(params[:id])
    @players = @team.players#.paginate(page: params[:page])
 #   @allplayers = Player.where.not(team_id: @team.id).includes(:team)

    if (positionFilter == "-1" && valueFilter == "-1")
      @allplayers = Player.where.not(team_id: @team.id).includes(:team)
    elsif (positionFilter != "-1" && valueFilter == "-1")
      case positionFilter
        when "1"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "GK").includes(:team)
        when "2"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "DEF").includes(:team)
        when "3"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "MID").includes(:team)
        when "4"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "FOR").includes(:team)
      end
    elsif (positionFilter == "-1" && valueFilter != "-1")
      @allplayers = Player.where.not(team_id: @team.id).where(value: 0..valueFilter.to_i).includes(:team)
    else
      case positionFilter
        when "1"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "GK").where(value: 0..valueFilter.to_i).includes(:team)
        when "2"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "DEF").where(value: 0..valueFilter.to_i).includes(:team)
        when "3"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "MID").where(value: 0..valueFilter.to_i).includes(:team)
        when "4"
          @allplayers = Player.where.not(team_id: @team.id).where(position: "FOR").where(value: 0..valueFilter.to_i).includes(:team)
      end
    end

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
