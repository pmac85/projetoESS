class TeamsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :transfers]
  before_action :correct_user
  before_action :check_actives, only: [:show]

  def index
    if current_user.admin
      @teams = Team.paginate(page: params[:page])
    else
      @teams = current_user.teams
    end
  end

  def show
    @team = Team.find(params[:id])
    @players = @team.players.order(:position)
  end

  def edit
    @team = Team.find(params[:id])
  end

  def transfers
    positionArray = ["GK","DEF","MID","FOR"]
    positionFilter = params[:positionFilter]
    valueFilter = params[:valueFilter]
    @team = Team.find(params[:id])
    @players = @team.players
    @allplayers = Player.where(is_chosen: false).includes(:team)

    if(positionFilter != nil && positionFilter != "-1")
      @allplayers = @allplayers.where(position: positionArray[positionFilter.to_i-1])
    end

    if(valueFilter != nil && valueFilter != "Unlimited")
      @allplayers = @allplayers.where(value: 0..valueFilter.to_i)
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

    @toBuy.update_all(team_id: @team.id, is_chosen: true)
    @toSell.update_all(team_id: nil, is_chosen: false, is_active: false)
    @team.update(budget: @team.budget+@toSell.sum(:value)-@toBuy.sum(:value))

    flash[:success] = "Transference successfully realized."

    render :nothing => true
  end


  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(team_params)
      flash[:success] = "Team profile updated."
      redirect_to team_path(current_user)
    else
      render 'edit'
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

  def choose_team
    @team = Team.find(params[:id])
    if current_user.teams.any?
      flash[:danger] = "You can't have more than one team."
      redirect_to root_path
    elsif current_user.admin
      flash[:danger] = "You can't have a team."
      redirect_to root_path
    else
      flash[:success] = "You have a new team. Enjoy."
      @team.update_attributes(user_id: current_user.id)
      redirect_to team_path
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

  def check_actives
    team = Team.find(params[:id]).players
    actives = team.where(is_active: true)
    gkall = team.where(position: "GK")
    defall = team.where(position: "DEF")
    midall = team.where(position: "MID")
    forall = team.where(position: "FOR")
    gka = actives.where(position: "GK")
    defa = actives.where(position: "DEF")
    mida = actives.where(position: "MID")
    fora = actives.where(position: "FOR")

    if !actives.empty?
      if actives.count != 11
        if gka.empty?
          gk = gkall.limit(1)
          gk.update_all(is_active: true)
        elsif gka.count == 2
          gk = gka.limit(1)
          gk.update_all(is_active: false)
        end
        check_actives_position(defa, defall, "DEF", 4, mida.count + fora.count, 6)
        check_actives_position(mida, midall, "MID", 4, defa.count + fora.count, 6)
        check_actives_position(fora, forall, "FOR", 2, mida.count + defa.count, 8)
      end
    else
      gk = team.where(position: "GK").limit(1)
      gk.update_all(is_active: true)
      defense = team.where(position: "DEF").limit(4)
      defense.update_all(is_active: true)
      mid = team.where(position: "MID").limit(4)
      mid.update_all(is_active: true)
      forward = team.where(position: "FOR").limit(2)
      forward.update_all(is_active: true)
    end
  end

  def check_actives_position(listaJog, team, pos, numDef, numNDef, numNDefPerm)
    if team.where(is_active: true).count != 11
      if listaJog.empty? && numNDef <= numNDefPerm
        players = team.where(position: pos).limit(numDef)
        players.update_all(is_active: true)
      elsif listaJog.empty? && numNDef == numNDefPerm+1
        players = team.where(position: pos).limit(numDef-1)
        players.update_all(is_active: true)
      else
        players = team.where(position: pos).limit(numDef - listaJog.count)
        players.update_all(is_active: true)
      end
    end
  end
end
