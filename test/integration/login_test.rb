require 'test_helper'

class Login < ActionDispatch::IntegrationTest

  def setup
    @password = "123456"
    @user = User.create!(username:  "Manel",
                 email:     "manel@mail.pt",
                 password:              @password,
                 password_confirmation: @password,
                 activated: true,
                 activated_at: Time.zone.now)
  end

  test "Login" do
    https!
    get "/login"
    assert_response :success

    post_via_redirect "/login", session: {email: @user.email, password: @password}
    assert_equal "/users/#{@user.id}", path

    https!(false)
  end

  test "Login Failure" do
    https!
    get "/login"
    assert_response :success

    post_via_redirect "/login", session: {email: @user.email, password: "invalidPass"}
    assert_equal "/login", path

    https!(false)
  end

  test "Login Failure2" do
    https!
    get "/login"
    assert_response :success

    post_via_redirect "/login", session: {email: "invalidEmail", password: "invalidPass"}
    assert_equal "/login", path

    https!(false)
  end

end