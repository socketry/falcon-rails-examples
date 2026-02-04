require "test_helper"

class JobControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get job_index_url
    assert_response :success
  end
end
