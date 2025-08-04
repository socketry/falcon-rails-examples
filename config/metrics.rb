# frozen_string_literal: true

# Run `bake metrics:provider:list` to see available providers.

def prepare
	require "metrics/provider/async/task"
	require "metrics/provider/async/container"
end
