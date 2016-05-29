require 'test_helper'

class HomeTest < ActionDispatch::IntegrationTest

  def setup
    @password = "123456"
    @user = User.create!(username:  "Manel",
                         email:     "manel@mail.pt",
                         password:              @password,
                         password_confirmation: @password,
                         activated: true,
                         activated_at: Time.zone.now)

  end

  test "Correct format" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "title", "Virtual Football League"
    assert_select "a[href=?]", "/"
    assert_select "a[href=?]", "/rules"
    assert_select "a[href=?]", "/login"
  end

  test "Correct format - LoggedIn" do
    https!
    get "/login"
    assert_response :success
    post_via_redirect "/login", session: {email: @user.email, password: @password}
    assert_equal "/users/#{@user.id}", path
    https!(false)

    get root_path
    follow_redirect!
    assert_template 'users/show'
    assert_select "title", "#{@user.username} | Virtual Football League"
    assert_select "a[href=?]", "/"
    assert_select "a[href=?]", "/users/#{@user.id}"
    assert_select "a[href=?]", "/rules"
    assert_select "a[href=?]", "/logout"
  end

  test "Correct format - LoggedIn With Team" do
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

    https!
    get "/login"
    assert_response :success
    post_via_redirect "/login", session: {email: @user.email, password: @password}
    assert_equal "/users/#{@user.id}", path
    https!(false)

    get root_path
    follow_redirect!
    assert_template 'users/show'
    assert_select "title", "#{@user.username} | Virtual Football League"
    assert_select "a[href=?]", "/"
    assert_select "a[href=?]", "/leagues/#{@league.id}"
    assert_select "a[href=?]", "/teams/#{@team.id}"
    assert_select "a[href=?]", "/teams/#{@team.id}/transfers"
    assert_select "a[href=?]", "/users/#{@user.id}"
    assert_select "a[href=?]", "/rules"
    assert_select "a[href=?]", "/logout"
  end
end