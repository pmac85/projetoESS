class PlayersController < ApplicationController

  def show
    @player = Player.find(params[:id])
  end

  def index
    @players = Player.paginate(page: params[:page])
  end

  def create

  end

  def destroy

  end

  private
  def player_params
    params.require(:player).permit(:name, :position, :value, :isChosen, :image_path)
  end
end
