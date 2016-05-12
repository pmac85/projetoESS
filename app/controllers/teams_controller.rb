class TeamsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :edit]
  before_action :correct_user

  def index
    if current_user.admin
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
    positionArray = ["GK","DEF","MID","FOR"]
    positionFilter = params[:positionFilter]
    valueFilter = params[:valueFilter]
    @team = Team.find(params[:id])
    @players = @team.players
    @allplayers = Player.where(is_chosen: false).includes(:team)

    if(positionFilter != nil && positionFilter != "-1")
      @allplayers = @allplayers.where(position: positionArray[positionFilter.to_i-1])
    end

    if(valueFilter != nil && valueFilter != "-1")
      @allplayers = @allplayers.where(value: 0..valueFilter.to_i);
    end
  end

  def transfer
    if(params['sell'] == nil)
      sell = []
    else
      sell = params['sell']
    end

    if(params['buy'] == nil)
      buy = []
    else
      buy = params['buy']
    end

    @team = Team.find(params[:id])
    @toSell = Player.where(id: sell)
    @toBuy = Player.where(id: buy)

    if(sell.length != buy.length)
      flash[:danger] = "Transferência não pode ser realizada! Pois não está a escolher o mesmo número de jogadores de cada lado"
      render :nothing => true
      return
    end

    if(@toSell.where(position: 'FOR').count != @toBuy.where(position: 'FOR').count ||
       @toSell.where(position: 'MID').count != @toBuy.where(position: 'MID').count ||
       @toSell.where(position: 'DEF').count != @toBuy.where(position: 'DEF').count ||
       @toSell.where(position: 'GK').count != @toBuy.where(position: 'GK').count)

      flash[:danger] = "Transferência não pode ser realizada. Está a selecionar jogadores de posições que não correspondem."
      render :nothing => true
      return
    end

    if(@toBuy.sum(:value) > @team.budget+@toSell.sum(:value))
      flash[:danger] = "Transferência não pode ser realizada. Está a tentar fazer transferências para as quais não tem orçamento."
      render :nothing => true
      return
    end

    @toBuy.update_all(team_id: @team.id)
    @toSell.update_all(team_id: nil)
    @team.update(budget: @team.budget+@toSell.sum(:value)-@toBuy.sum(:value))

    flash[:success] = "Transference successfully realized."

    render :nothing => true
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

  def changeStrategy
    @team = Team.find(params[:id])

    @team.players.update_all(is_active: false)

    ids = []
    ['FOR','MID','DEF','GK'].each do |pos|
      ids += params[pos] if(params[pos] != nil)
    end

    @team.players.where(id: ids).update_all(is_active: true)

    render :nothing => true
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
