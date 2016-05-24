require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new( username:  "Name Test",
                      email:     "nameTest@mail.pt",
                      password:              "passTest",
                      password_confirmation: "passTest",
                      admin: false,
                      activated: true,
                      activated_at: Time.zone.now)
  end

  test "Valid user" do
    assert @user.valid?
  end

  test "Email is not nil" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "Name is not nil" do
    @user.username = nil
    assert_not @user.valid?
  end

  test "Password is not nil" do
    @user.password = nil
    @user.password_confirmation = nil
    assert_not @user.valid?
  end

  test "Password must match" do
    @user.password = "123456"
    @user.password_confirmation = "654321"
    assert_not @user.valid?
  end

end
