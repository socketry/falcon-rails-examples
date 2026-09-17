require "test_helper"

class GameControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get game_index_url

    assert_response :success
    assert_select "live-view#game[data-class='GameTag']"
    assert_select ".game[onkeydown]"
  end
end
