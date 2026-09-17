class SseController < ApplicationController
	def index
	end

	EVENT_STREAM_HEADERS = {
		'content-type' => 'text/event-stream',
		'cache-control' => 'no-cache',
		'x-accel-buffering' => 'no',
	}
	
	def self.event_stream(interval: 1, clock: Time)
		proc do |stream|
			sequence = 0
			
			loop do
				sequence += 1
				stream.write("id: #{sequence}\ndata: #{clock.now}\n\n")
				sleep interval
			end
		rescue IOError, Errno::EPIPE
			# The client disconnected.
		end
	end

	def events
		body = self.class.event_stream
		
		self.response = Rack::Response[200, EVENT_STREAM_HEADERS.dup, body]
	end
end
