require "test_helper"
require "minitest/mock"

class OllamaControllerTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  test "renders a signed subscription and a form that waits for Cable" do
    get ollama_index_url

    assert_response :success
    assert_select '[data-controller="ollama"]' do |elements|
      token = elements.first["data-ollama-conversation-value"]
      assert Conversation.find_signed(token, purpose: :ollama)
    end
    assert_select 'button[data-ollama-target="send"][disabled]'
    assert_select 'input[data-ollama-target="prompt"][disabled]'
    assert_select 'script[type="importmap"]' do |elements|
      imports = JSON.parse(elements.first.content).fetch("imports")
      assert_match %r{actioncable\.esm.*\.js}, imports.fetch("@rails/actioncable")
    end
  end

  test "broadcasts incremental answers before saving the completed exchange" do
    conversation = conversations(:one)
    stream = OllamaChannel.broadcasting_for(conversation)
    original_count = conversation.conversation_messages.count
    client = Object.new
    client.define_singleton_method(:models) { Struct.new(:names).new([conversation.model]) }
    submitted_messages = nil
    body = Enumerator.new do |output|
      assert_equal original_count, conversation.conversation_messages.count
      output << "Hello"
      assert_equal "Hello", JSON.parse(broadcasts(stream).last)["content"]
      assert_equal original_count, conversation.conversation_messages.count
      output << " there"
    end
    client.define_singleton_method(:chat) do |messages, **options, &block|
      submitted_messages = messages.deep_dup
      block.call(Struct.new(:body).new(body))
      Struct.new(:response, :message, :tool_calls, :error).new(
        "Hello there", {role: "assistant", content: "Hello there"}, nil, nil
      )
    end

    Async::Ollama::Client.stub(:open, ->(&block) { block.call(client) }) do
      post ollama_reply_url, params: {
        conversation: conversation.signed_id(purpose: :ollama),
        request_id: "turn-1", prompt: "Explain fibers.",
      }, as: :json
    end

    assert_response :success
    assert_equal "Hello there", response.parsed_body["content"]
    assert_equal "<p>Hello there</p>\n", response.parsed_body["html"]
    assert_equal "turn-1", response.parsed_body["request_id"]
    assert_equal ["Hello", "Hello there"], broadcasts(stream).map { |message| JSON.parse(message)["content"] }
    assert_equal ["turn-1", "turn-1"], broadcasts(stream).map { |message| JSON.parse(message)["request_id"] }
    assert_equal 1, submitted_messages.count { |message| message[:content] == "Explain fibers." }
    assert_equal "Hello, how are you?", submitted_messages.first[:content]
    assert_equal original_count + 2, conversation.conversation_messages.count
    assert_equal ["user", "assistant"], conversation.conversation_messages.order(:id).last(2).map(&:role)
    assert_equal "Hello there", conversation.conversation_messages.order(:id).last.content
  end

  test "rejects an unsigned conversation before starting generation" do
    post ollama_reply_url, params: {
      conversation: conversations(:one).id, request_id: "turn-1", prompt: "Hello",
    }, as: :json

    assert_response :not_found
  end

  test "rejects a blank prompt without saving messages" do
    assert_no_difference "ConversationMessage.count" do
      post ollama_reply_url, params: {
        conversation: conversations(:one).signed_id(purpose: :ollama),
        request_id: "turn-1", prompt: "   ",
      }, as: :json
    end

    assert_response :unprocessable_content
  end

  test "reopens a saved conversation with formatted replies" do
    conversation = conversations(:one)
    conversation.conversation_messages.create!(role: "assistant", content: "**Saved answer**")

    assert_no_difference "Conversation.count" do
      get ollama_index_url, params: {id: conversation.id}
    end

    assert_response :success
    assert_select ".messages .prompt", text: "Hello, how are you?"
    assert_select ".messages .response strong", text: "Saved answer"
    assert_select '[data-controller="ollama"]' do |elements|
      token = elements.first["data-ollama-conversation-value"]
      assert_equal conversation, Conversation.find_signed(token, purpose: :ollama)
    end
  end

  test "uses an installed model when the configured model is unavailable" do
    conversation = Conversation.create!(model: "missing:latest")
    client = fake_client(models: ["available:latest"])

    with_client(client) { submit_prompt(conversation) }

    assert_response :success
    assert_equal "available:latest", conversation.reload.model
  end

  test "broadcasts sanitized Markdown and returns the same formatted answer" do
    conversation = conversations(:one)
    content = "**Hello**\n\n<script>alert('unsafe')</script>\n\n[link](javascript:alert('unsafe'))"
    client = fake_client(models: [conversation.model], content: content)

    with_client(client) { submit_prompt(conversation) }

    assert_response :success
    html = response.parsed_body.fetch("html")
    assert_includes html, "<strong>Hello</strong>"
    refute_includes html, "<script>"
    refute_includes html, "javascript:"
    update = JSON.parse(broadcasts(OllamaChannel.broadcasting_for(conversation)).last)
    assert_equal html, update.fetch("html")
  end

  test "does not save a partial exchange when the model stream fails" do
    conversation = conversations(:one)
    body = Enumerator.new do |output|
      output << "Partial answer"
      raise IOError, "Model connection closed"
    end
    client = fake_client(models: [conversation.model], body: body)

    assert_no_difference "ConversationMessage.count" do
      assert_raises(IOError) do
        with_client(client) { submit_prompt(conversation) }
      end
    end
  end

  private

  def submit_prompt(conversation)
    post ollama_reply_url, params: {
      conversation: conversation.signed_id(purpose: :ollama),
      request_id: "turn-1", prompt: "Hello",
    }, as: :json
  end

  def with_client(client, &block)
    Async::Ollama::Client.stub(:open, ->(&handler) { handler.call(client) }, &block)
  end

  def fake_client(models:, content: "Hello there", body: [content])
    Object.new.tap do |client|
      client.define_singleton_method(:models) { Struct.new(:names).new(models) }
      client.define_singleton_method(:chat) do |messages, **options, &block|
        block.call(Struct.new(:body).new(body))
        Struct.new(:response, :message, :tool_calls, :error).new(
          content, {role: "assistant", content: content}, nil, nil
        )
      end
    end
  end
end
