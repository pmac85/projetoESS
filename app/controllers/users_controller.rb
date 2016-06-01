class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @teams = @user.teams
    if @teams.any?
    place=League.where(id:@teams.first.league_id).first.teams.all.order('total_score DESC, goals_scored DESC, goals_suffered ASC')
    @index=1
    place.each do |p|
      if(p==@teams.first)
        break
      end
      @index+=1
    end
      end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.activate
      log_in @user
      flash[:success] = "Account created! Enjoy the game."
      redirect_to user_path(current_user)
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id]).destroy
    #flash[:success] = "User deleted"
    respond_to do |format|
      format.html {redirect_to users_url}
      format.js
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  # Before filters

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    return if(current_user.admin)
    redirect_to(root_url) unless @user == current_user
  end


end
