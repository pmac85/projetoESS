class TeamsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def index
    @teams = Team.paginate(page: params[:page])
  end

  def show
    @team = Team.find(params[:id])
    @players = @team.players.paginate(page: params[:page])
    if false
      @team = Team.find(params[:id])
      @players = @team.players.paginate(page: params[:page])
    else
      @allplayers = Player.where("team_id != ?", @team.id).paginate(page:params[:page], :per_page => 15)
      render 'players/transfer'
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
    @team.destroy
    flash[:success] = "Team deleted"
    redirect_to request.referrer || root_url
  end

  private
  def team_params
    params.require(:team).permit(:name)
  end

  def correct_user
    @team = current_user.teams.find_by(id: params[:id])
    redirect_to root_url if @team.nil?
  end
end
