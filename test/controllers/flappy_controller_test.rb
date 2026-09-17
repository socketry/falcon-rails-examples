require "test_helper"

class FlappyControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get flappy_index_url
    assert_response :success
    assert_select "live-view#flappy[data-class='FlappyTag']"
    assert_select ".flappy[onkeydown][onpointerdown]"

    # Exercise session cookie deserialization on a subsequent request.
    get flappy_index_url
    assert_response :success
  end
end
