require "async/ollama"

class OllamaController < ApplicationController
  def index
    if id = params[:id]
      @conversation = Conversation.find(id)
    else
      @conversation = Conversation.create!(model: Async::Ollama::MODEL)
    end
  end

  def reply
    conversation = Conversation.find_signed(params.require(:conversation).to_s, purpose: :ollama)
    raise ActiveRecord::RecordNotFound unless conversation

    prompt = params[:prompt].to_s.strip
    request_id = params.require(:request_id).to_s
    return render json: {error: "Enter a prompt."}, status: :unprocessable_content if prompt.empty?

    content = generate_reply(conversation, prompt, request_id)
    render json: {request_id: request_id, content: content, html: helpers.ollama_response_html(content)}
  end

  private

  def generate_reply(conversation, prompt, request_id)
    Sync do
      Async::Ollama::Client.open do |client|
        models = client.models.names
        unless models.include?(conversation.model)
          model = models.first or raise "No Ollama models are installed. Run `ollama pull #{Async::Ollama::MODEL}` first."
          conversation.update!(model: model)
        end

        agent_conversation = conversation.agent_conversation(client)
        content = +""

        chat = agent_conversation.call(prompt) do |response|
          response.body.each do |piece|
            content << piece
            OllamaChannel.broadcast_to(conversation,
              request_id: request_id, content: content, html: helpers.ollama_response_html(content))
          end
        end

        conversation.transaction do
          conversation.conversation_messages.create!(role: "user", content: prompt)
          conversation.conversation_messages.create!(role: "assistant", content: chat.response)
        end

        chat.response
      end
    end
  end
end
