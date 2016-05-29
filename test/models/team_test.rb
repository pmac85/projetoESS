require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  def setup
    @password = "123456"
    @user = User.create!(
        username:  "Manel",
        email:     "manel@mail.pt",
        password:              @password,
        password_confirmation: @password,
        activated: true,
        activated_at: Time.zone.now
    )

    @league = League.create!(
        name: "Liga teste",
        initial_date: Time.zone.now
    )

    @team = Team.create!(
        name: "Team teste",
        budget: 500,
        user_id: @user.id,
        league_id: @league.id
    )

    @tp1 = Player.create(name:"Joe Hart", position:"GK", value:62, team_id: @team.id)
    @tp2 = Player.create(name:"Samir Nasri", position:"FOR", value:67, team_id: @team.id)
    @tp3 = Player.create(name:"Jesús Navas", position:"FOR", value:61, team_id: @team.id)
    @tp4 = Player.create(name:"David Silva", position:"MID", value:70, team_id: @team.id)
    @tp5 = Player.create(name:"Blaise Matuidi", position:"MID", value:65, team_id: @team.id)
    @tp6 = Player.create(name:"Adrien Rabiot", position:"MID", value:54, team_id: @team.id)
    @tp7 = Player.create(name:"Javier Pastore", position:"MID", value:65, team_id: @team.id)
    @tp8 = Player.create(name:"Eliaquim Mangala", position:"DEF", value:66, team_id: @team.id)
    @tp9 = Player.create(name:"Vincent Kompany", position:"DEF", value:66, team_id: @team.id)
    @tp10 = Player.create(name:"Martín Demichelis", position:"DEF", value:52, team_id: @team.id)
    @tp11 = Player.create(name:"Aleksandar Kolarov", position:"DEF", value:57, team_id: @team.id)
  end

  test "More than 1 team in league" do
    assert_not Team.create!(
        name: "Team2",
        budget: 500,
        user_id: @user.id,
        league_id: @league.id
    ).valid?
  end

  test "More than 1 team in different leagues" do
    @l2 = League.create!(
        name: "Liga2",
        initial_date: Time.zone.now
    )
    assert Team.create!(
        name: "Team2",
        budget: 500,
        user_id: @user.id,
        league_id: @l2.id
    ).valid?
  end

  test "More than 15 players" do
    Player.create!(name:"Javier Pastore", position:"GK", value:65, team_id: @team.id)
    Player.create!(name:"Eliaquim Mangala", position:"FOR", value:66, team_id: @team.id)
    Player.create!(name:"Vincent Kompany", position:"FOR", value:66, team_id: @team.id)
    Player.create!(name:"Martín Demichelis", position:"DEF", value:52,  team_id: @team.id)

    assert_not Player.create!(name:"Aleksandar Kolarov", position:"MID", value:57, team_id: @team.id).valid?
  end

  test "More than 2 GK" do
    Player.create!(name:"Javier Pastore", position:"GK", value:65, team_id: @team.id)
    assert_not Player.create!(name:"Javier Pastore", position:"GK", value:65, team_id: @team.id).valid?
  end

  test "More than 5 DEF" do
    Player.create!(name:"Javier Pastore", position:"DEF", value:65, team_id: @team.id)
    assert_not Player.create!(name:"Javier Pastore", position:"DEF", value:65, team_id: @team.id).valid?
  end

  test "More than 5 MID" do
    Player.create!(name:"Javier Pastore", position:"MID", value:65, team_id: @team.id)
    assert_not Player.create!(name:"Javier Pastore", position:"MID", value:65, team_id: @team.id).valid?
  end

  test "More than 3 FOR" do
    Player.create!(name:"Javier Pastore", position:"FOR", value:65, team_id: @team.id)
    assert_not Player.create!(name:"Javier Pastore", position:"FOR", value:65, team_id: @team.id).valid?
  end
end
