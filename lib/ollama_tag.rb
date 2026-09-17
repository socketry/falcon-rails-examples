# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require "live"
require "async/ollama"
require "async/ollama/toolbox"
require "markly"

class OllamaTag < Live::View
	def initialize(...)
		super
		
		@conversation = nil
	end
	
	def conversation
		@conversation ||= Conversation.find_by(id: @data[:conversation_id])
	end
	
	def append_prompt(client, prompt)
		conversation_prompt = conversation.conversation_messages.create!(role: "user", content: prompt)
		conversation_reply = conversation.conversation_messages.create!(role: "assistant", content: "")
		
		self.append(".conversation .messages") do |builder|
			self.render_message(builder, conversation_prompt)
			self.render_message(builder, conversation_reply)
		end
		
		agent_conversation = conversation.agent_conversation(client)
		chat = agent_conversation.call(prompt) do |response|
			response.body.each do |token|
				conversation_reply.content += token
				
				self.replace(".message.id#{conversation_reply.id}") do |builder|
					self.render_message(builder, conversation_reply)
				end
			end
		end
		
		conversation_reply.content = chat.response
		conversation_reply.save!
		
		return conversation_reply
	end
	
	def update_conversation(prompt)
		Console.info(self, "Updating conversation", id: conversation.id, prompt: prompt)
		
		Async::Ollama::Client.open do |client|
			select_available_model(client)
			append_prompt(client, prompt)
		end
	end
	
	def select_available_model(client)
		models = client.models.names
		return if models.include?(conversation.model)
		
		if model = models.first
			Console.warn(self, "Configured model is not installed; using an available model", configured: conversation.model, selected: model)
			conversation.update!(model: model)
		else
			raise "No Ollama models are installed. Run `ollama pull #{Async::Ollama::MODEL}` first."
		end
	end
	
	def report_error(error)
		Console.error(self, error)
		
		self.append(".conversation .messages") do |builder|
			builder.tag(:div, class: "message error") do
				builder.text("Ollama error: #{error.message}")
			end
		end
	end
	
	def handle(event)
		case event[:type]
		when "keydown"
			detail = event[:detail]
			
			if detail[:key] == "Enter" && (prompt = detail[:value].to_s.strip).length > 0
				
				Async do
					begin
						update_conversation(prompt)
					rescue => error
						report_error(error)
					end
				end
			end
		end
	end
	
	def forward_keydown
		"if (event.key === 'Enter') { event.preventDefault(); live.forwardEvent(#{JSON.dump(@id)}, event, {value: event.target.value, key: event.key}); event.target.value = ''; }"
	end
	
	def render_message(builder, message)
		builder.tag(:div, class: "message id#{message.id}") do
			if message.role == "user"
				builder.inline_tag(:p, class: "prompt") do
					builder.text(message.content)
				end
			else
				builder.inline_tag(:div, class: "response") do
					builder.raw(Markly.render_html(message.content, extensions: %i[autolink table]))
				end
			end
		end
	end
	
	def render(builder)
		builder.tag(:div, class: "conversation") do
			builder.tag(:div, class: "messages") do
				conversation&.conversation_messages&.each do |message|
					render_message(builder, message)
				end
			end
			
			builder.tag(:input, type: "text", class: "prompt", value: @data[:prompt], onkeydown: forward_keydown, autofocus: true, placeholder: "Type prompt here...")
		end
	end
end
