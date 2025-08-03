class Conversation < ApplicationRecord
	has_many :conversation_messages
	
	def messages
		self.conversation_messages.order(created_at: :asc).map do |message|
			{
				role: message.role,
				content: message.content,
			}
		end
	end
	
	def agent_conversation(client)
		Async::Ollama::Conversation.new(client, model: self.model, messages: self.messages)
	end
end
