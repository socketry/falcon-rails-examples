require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/"
    assert_response :success
  end
end
