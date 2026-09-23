class OllamaChannel < ApplicationCable::Channel
  def subscribed
    if conversation = Conversation.find_signed(params[:conversation].to_s, purpose: :ollama)
      stream_for conversation
    else
      reject
    end
  end
end
