require "test_helper"

class SseControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sse_index_url
    assert_response :success
  end

  test "should stream server-sent events" do
    time = Time.new(2026, 9, 17, 13, 48, 36, "+12:00")
    clock = Struct.new(:now).new(time)
    writes = []
    stream = Object.new
    stream.define_singleton_method(:write) do |event|
      raise Errno::EPIPE if writes.length == 2

      writes << event
    end

    SseController.event_stream(interval: 0, clock: clock).call(stream)

    assert_equal [
      "id: 1\ndata: 2026-09-17 13:48:36 +1200\n\n",
      "id: 2\ndata: 2026-09-17 13:48:36 +1200\n\n"
    ], writes
    assert_equal "text/event-stream", SseController::EVENT_STREAM_HEADERS["content-type"]
    assert_equal "no-cache", SseController::EVENT_STREAM_HEADERS["cache-control"]
    assert_equal "no", SseController::EVENT_STREAM_HEADERS["x-accel-buffering"]
  end
end
