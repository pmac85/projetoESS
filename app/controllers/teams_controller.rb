class TeamsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy, :transfers, :changeStrategy]
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

    if positionFilter != nil && positionFilter != "-1"
      @allplayers = @allplayers.where(position: positionArray[positionFilter.to_i-1])
    end

    if valueFilter != nil && valueFilter != "Unlimited"
      @allplayers = @allplayers.where(value: 0..valueFilter.to_i)
    end
  end


  def transfer
    if params['sell'] == nil
      sell = []
    else
      sell = params['sell']
    end

    if params['buy'] == nil
      buy = []
    else
      buy = params['buy']
    end

    @team = Team.find(params[:id])
    @toSell = Player.where(id: sell)
    @toBuy = Player.where(id: buy)

    if sell.length != buy.length
      flash[:danger] = "Cannot make transfer! You didn't choose the same number of player to trade"
      render :nothing => true
      return
    end

    if @toSell.where(position: 'FOR').count != @toBuy.where(position: 'FOR').count ||
       @toSell.where(position: 'MID').count != @toBuy.where(position: 'MID').count ||
       @toSell.where(position: 'DEF').count != @toBuy.where(position: 'DEF').count ||
       @toSell.where(position: 'GK').count != @toBuy.where(position: 'GK').count

      flash[:danger] = "Cannot make transfer! The selected players are not from the same position."
      render :nothing => true
      return
    end

    if @toBuy.sum(:value) > @team.budget+@toSell.sum(:value)
      flash[:danger] = "Cannot make transfer! You don't have enough budget."
      render :nothing => true
      return
    end

    if @toBuy.where.not(team_id:nil).count !=0
      flash[:danger] = "Cannot make transfer! One or more choosen players are not avaliable anymore."
      p(@toBuy)
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
      redirect_to team_path(current_user.teams.first.id)
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

  def drop_user
    @team = Team.where(params[:id]).update_all(user_id: nil)
    @team1 = Team.find(params[:id])
    flash[:success] = "You are no longer #{@team1.name} manager. Choose a new team."
    redirect_to league_path(@team1.league_id)
  end

  def changeStrategy
    @team = Team.find(params[:id])

    ids = []
    limit = {
        'FOR' => [0,3],
        'MID' => [0,5],
        'DEF' => [0,5],
        'GK' => [1,1]
    }
    ['FOR','MID','DEF','GK'].each do |pos|
      params[pos] = [] if(params[pos] == nil)

      if(params[pos].size < limit[pos][0] || params[pos].size > limit[pos][1])
        flash[:danger] = "Invalid number of players in #{pos} position."
        render :nothing => true
        return
      end

      ids += params[pos]
    end

    @team.players.update_all(is_active: false)
    @team.players.where(id: ids).update_all(is_active: true)

    flash[:success] = "Strategy changed successfully."
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
    params.require(:team).permit(:name, :image_path, :user_id)
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
      if actives.count < 11
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
      gk = team.where(position: "GK", is_active: false).limit(1)
      gk.update_all(is_active: true)
      defense = team.where(position: "DEF", is_active: false).limit(4)
      defense.update_all(is_active: true)
      mid = team.where(position: "MID", is_active: false).limit(4)
      mid.update_all(is_active: true)
      forward = team.where(position: "FOR", is_active: false).limit(2)
      forward.update_all(is_active: true)
    end
  end

  def check_actives_position(listaJog, team, pos, numDef, numNDef, numNDefPerm)
    if team.where(is_active: true).count != 11
      if listaJog.empty?
        if numNDef <= numNDefPerm
          players = team.where(position: pos, is_active: false).limit(numDef)
          players.update_all(is_active: true)
        elsif numNDef == numNDefPerm+1
          players = team.where(position: pos, is_active: false).limit(numDef-1)
          players.update_all(is_active: true)
        else
          players = team.where(position: pos, is_active: false).limit(numDef - listaJog.count)
          players.update_all(is_active: true)
        end
      else
        if numNDef <= numNDefPerm
          players = team.where(position: pos, is_active: false).limit(numDef - listaJog.count)
          players.update_all(is_active: true)
        elsif numNDef == numNDefPerm+1
          players = team.where(position: pos, is_active: false).limit(numDef - 1 - listaJog.count)
          players.update_all(is_active: true)
        end
      end
    end
  end
end
