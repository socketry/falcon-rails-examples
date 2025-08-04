def make_output(io = nil, env = ENV, **options)
	require "console/output/datadog"
	
	Console::Output::Datadog.new(super)
rescue LoadError
	super
end
