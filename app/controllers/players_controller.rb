class PlayersController < ApplicationController

  def show
    @player = Player.find(params[:id])
  end

  def index
    @players = Player.all
  end

  def create

  end

  def destroy

  end

  private
  def player_params
    params.require(:player).permit(:name, :position, :value, :is_chosen, :image_path, :real_team, :is_active)
  end
end
