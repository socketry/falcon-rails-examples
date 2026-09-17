require "test_helper"

class StreamingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get streaming_index_url
    assert_response :success
  end
end
