require "test_helper"

class OllamaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ollama_index_url

    assert_response :success
    assert_select "live-view#ollama[data-class='OllamaTag'][data-conversation_id]"
    assert_select ".conversation input.prompt[onkeydown]"
    assert_select ".conversation input.prompt[onkeypress]", count: 0
  end

  test "uses an installed model when the configured model is unavailable" do
    conversation = Conversation.create!(model: "missing:latest")
    tag = OllamaTag.root("ollama", data: {conversation_id: conversation.id})
    models = Struct.new(:names).new(["available:latest"])
    client = Struct.new(:models).new(models)

    tag.select_available_model(client)

    assert_equal "available:latest", conversation.reload.model
  end
end
