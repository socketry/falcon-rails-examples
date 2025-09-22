# frozen_string_literal: true

# Run `bake traces:provider:list` to see available providers.

# config/traces.rb

def prepare
	# Add HTTP/2 protocol traces:
	# require "traces/provider/protocol/http2"
	require "traces/provider/async"
	require "traces/provider/async/http"
end