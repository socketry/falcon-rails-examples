#!/usr/bin/env falcon-host
# frozen_string_literal: true

require "falcon/environment/rack"
require "falcon/environment/lets_encrypt_tls"
require "falcon/environment/supervisor"
require "async/job/adapter/active_job/environment"

hostname = File.basename(__dir__)
service "www.example.com" do
	include Falcon::Environment::Rack
	include Falcon::Environment::LetsEncryptTLS

	# port {ENV.fetch("PORT", 3000).to_i}
	# endpoint {Async::HTTP::Endpoint.parse("http://localhost", port: port)}
end

# service "background-jobs" do
# 	include Async::Job::Adapter::ActiveJob::Environment
# end

# service "supervisor" do
# 	include Falcon::Environment::Supervisor
# end
