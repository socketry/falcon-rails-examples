require "test_helper"

class FlappyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get flappy_index_url
    assert_response :success
  end
end
