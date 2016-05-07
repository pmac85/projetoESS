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
=begin
    positionFilter = params[:positionFilter]
    valueFilter = params[:valueFilter]
    @response = []
=end
    @team = Team.find(params[:id])
    @players = @team.players.paginate(page: params[:page])
    @allplayers = Player.where("team_id != ?", @team.id).all
=begin

    if (positionFilter == "-1" && valueFilter == "-1")
      @allplayers = Player.where("team_id != ?", @team.id)
      for player in @allplayers
        @response.push(render player)
      end
    else
      @allplayers = Player.where("team_id != ?", @team.id).all
    end
=end
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
