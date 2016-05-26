require 'test_helper'

class Team_Test < ActionDispatch::IntegrationTest

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

    @tp1 = Player.create(name:"Joe Hart", position:"GK", value:62, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp2 = Player.create(name:"Samir Nasri", position:"FOR", value:67, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp3 = Player.create(name:"Jesús Navas", position:"FOR", value:61, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp4 = Player.create(name:"David Silva", position:"MID", value:70, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp5 = Player.create(name:"Blaise Matuidi", position:"MID", value:65, real_team:"PSG", team_id: @team.id, is_chosen: true, is_active: true)
    @tp6 = Player.create(name:"Adrien Rabiot", position:"MID", value:54, real_team:"PSG", team_id: @team.id, is_chosen: true, is_active: true)
    @tp7 = Player.create(name:"Javier Pastore", position:"MID", value:65, real_team:"PSG", team_id: @team.id, is_chosen: true, is_active: true)
    @tp8 = Player.create(name:"Eliaquim Mangala", position:"DEF", value:66, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp9 = Player.create(name:"Vincent Kompany", position:"DEF", value:66, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp10 = Player.create(name:"Martín Demichelis", position:"DEF", value:52, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)
    @tp11 = Player.create(name:"Aleksandar Kolarov", position:"DEF", value:57, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: true)

    @p1 = Player.create(name:"Test1", position:"FOR", value:50, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: false)
    @p2 = Player.create(name:"Test2", position:"FOR", value:60, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: false)
    @p3 = Player.create(name:"Test3", position:"GK", value:70, real_team:"ManCity", team_id: @team.id, is_chosen: true, is_active: false)

    @pa = Player.create(name:"Test4", position:"FOR", value:50, real_team:"ManCity")
    @pb = Player.create(name:"Test5", position:"DEF", value:60, real_team:"ManCity")
    @pc = Player.create(name:"Test6", position:"GK", value:70, real_team:"ManCity")

    https!
    get "/login"
    post_via_redirect "/login", session: {email: @user.email, password: @password}
    https!(false)
  end

  test "See team" do
    get "/teams"
    assert_response :success

    get "/teams/#{@team.id}"
    assert_response :success
  end

  test "Strategy Test 1" do
    post "/teams/#{@team.id}/strategy",
         GK: [@tp1.id],
         FOR: [@tp2.id,@tp3.id],
         MID: [@tp4.id,@tp5.id,@tp6.id,@tp7.id],
         DEF: [@tp8.id,@tp9.id,@tp10.id,@tp11.id]
    players = Team.find(@team.id).players
    assert_equal [@tp1.id].sort,
                 players.where(is_active: true, position: "GK").pluck(:id).sort
    assert_equal [@tp2.id,@tp3.id].sort,
                 players.where(is_active: true, position: "FOR").pluck(:id).sort
    assert_equal [@tp4.id,@tp5.id,@tp6.id,@tp7.id].sort,
                 players.where(is_active: true, position: "MID").pluck(:id).sort
    assert_equal [@tp8.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 players.where(is_active: true, position: "DEF").pluck(:id).sort
    assert_equal [@p1.id,@p2.id,@p3.id].sort,
                 players.where(is_active: false).pluck(:id).sort
  end

  test "Strategy Test 2 - Remove MID Add GK" do
    post "/teams/#{@team.id}/strategy",
         GK: [@tp1.id,@p3.id],
         FOR: [@tp2.id,@tp3.id],
         MID: [@tp4.id,@tp5.id,@tp6.id],
         DEF: [@tp8.id,@tp9.id,@tp10.id,@tp11.id]
    players = Team.find(@team.id).players
    assert_equal [@tp1.id,@p3.id].sort,
                 players.where(is_active: true, position: "GK").pluck(:id).sort
    assert_equal [@tp2.id,@tp3.id].sort,
                 players.where(is_active: true, position: "FOR").pluck(:id).sort
    assert_equal [@tp4.id,@tp5.id,@tp6.id].sort,
                 players.where(is_active: true, position: "MID").pluck(:id).sort
    assert_equal [@tp8.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 players.where(is_active: true, position: "DEF").pluck(:id).sort
    assert_equal [@p1.id,@p2.id,@tp7.id].sort,
                 players.where(is_active: false).pluck(:id).sort
  end

  test "Strategy Test 3 - Remove GK Add FOR" do
    post "/teams/#{@team.id}/strategy",
         GK: [],
         FOR: [@tp2.id,@tp3.id,@p2.id],
         MID: [@tp4.id,@tp5.id,@tp6.id,@tp7.id],
         DEF: [@tp8.id,@tp9.id,@tp10.id,@tp11.id]
    players = Team.find(@team.id).players
    assert_equal [],
                 players.where(is_active: true, position: "GK").pluck(:id).sort
    assert_equal [@tp2.id,@tp3.id,@p2.id].sort,
                 players.where(is_active: true, position: "FOR").pluck(:id).sort
    assert_equal [@tp4.id,@tp5.id,@tp6.id,@tp7.id].sort,
                 players.where(is_active: true, position: "MID").pluck(:id).sort
    assert_equal [@tp8.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 players.where(is_active: true, position: "DEF").pluck(:id).sort
    assert_equal [@tp1.id,@p1.id,@p3.id].sort,
                 players.where(is_active: false).pluck(:id).sort
  end

  test "See transfers" do
    get "/teams/#{@team.id}/transfers"
    assert_response :success
  end

  test "Transfer Test 1 - Não faz nada" do
    post "/teams/#{@team.id}/transfer",
         buy: [],
         sell: []
    assert_equal [@p1.id,@p2.id,@p3.id,@tp1.id,@tp2.id,@tp3.id,@tp4.id,@tp5.id,@tp6.id,@tp7.id,@tp8.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 Player.where(team_id: @team.id).pluck(:id).sort
    assert_equal [@pa.id,@pb.id,@pc.id].sort,
                 Player.where(team_id: nil).pluck(:id).sort
    assert_equal 500,
                 Team.find(@team.id).budget
  end

  test "Transfer Test 2 - Vender e comprar 1" do
    post "/teams/#{@team.id}/transfer",
         buy: [@pa.id],
         sell: [@tp2.id]

    assert_equal [@pa.id,@p1.id,@p2.id,@p3.id,@tp1.id,@tp3.id,@tp4.id,@tp5.id,@tp6.id,@tp7.id,@tp8.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 Player.where(team_id: @team.id).pluck(:id).sort
    assert_equal [@pb.id,@pc.id,@tp2.id].sort,
                 Player.where(team_id: nil).pluck(:id).sort
    assert_equal 500-@pa.value+@tp2.value,
                 Team.find(@team.id).budget
  end

  test "Transfer Test 3 - Vender e comprar posições diferentes" do
    post "/teams/#{@team.id}/transfer",
         buy: [@pa.id],
         sell: [@tp1.id]

    assert_equal [@p1.id,@p2.id,@p3.id,@tp1.id,@tp2.id,@tp3.id,@tp4.id,@tp5.id,@tp6.id,@tp7.id,@tp8.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 Player.where(team_id: @team.id).pluck(:id).sort
    assert_equal [@pa.id,@pb.id,@pc.id].sort,
                 Player.where(team_id: nil).pluck(:id).sort
    assert_equal 500,
                 Team.find(@team.id).budget
  end

  test "Transfer Test 3 - Vender e comprar vários jogadores de posições diferentes" do
    post "/teams/#{@team.id}/transfer",
         buy: [@pa.id,@pb.id,@pc.id],
         sell: [@tp1.id,@tp2.id,@tp8.id]

    assert_equal [@pa.id,@pb.id,@pc.id,@p1.id,@p2.id,@p3.id,@tp3.id,@tp4.id,@tp5.id,@tp6.id,@tp7.id,@tp9.id,@tp10.id,@tp11.id].sort,
                 Player.where(team_id: @team.id).pluck(:id).sort
    assert_equal [@tp1.id,@tp2.id,@tp8.id].sort,
                 Player.where(team_id: nil).pluck(:id).sort
    assert_equal 500-(@pa.value+@pb.value+@pc.value)+(@tp1.value+@tp2.value+@tp8.value),
                 Team.find(@team.id).budget
  end

end