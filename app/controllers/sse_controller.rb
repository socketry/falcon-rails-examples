class SseController < ApplicationController
	def index
	end

	EVENT_STREAM_HEADERS = {
		'content-type' => 'text/event-stream',
	}

	def events
		body = proc do |stream|
			5.times do
				stream.write("data: #{Time.now}\n\n")
				sleep 0.05
			end
		end
		
		self.response = Rack::Response[200, EVENT_STREAM_HEADERS.dup, body]
	end
end
