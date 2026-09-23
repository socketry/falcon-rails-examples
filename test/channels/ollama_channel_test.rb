require "test_helper"

class OllamaChannelTest < ActionCable::Channel::TestCase
  test "subscribes to the signed conversation" do
    conversation = conversations(:one)
    subscribe conversation: conversation.signed_id(purpose: :ollama)

    assert subscription.confirmed?
    assert_has_stream_for conversation
  end

  test "rejects an unsigned conversation ID" do
    subscribe conversation: conversations(:one).id

    assert subscription.rejected?
  end

  test "rejects a token issued for another purpose" do
    subscribe conversation: conversations(:one).signed_id(purpose: :another_example)

    assert subscription.rejected?
  end
end
