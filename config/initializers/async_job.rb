
require 'async/job'
require 'async/job/processor/aggregate'
require 'async/job/processor/redis'
require 'async/job/processor/inline'

Rails.application.configure do
	config.async_job.define_queue "default" do
		enqueue Async::Job::Processor::Aggregate
		dequeue Async::Job::Processor::Redis
	end
	
	config.async_job.define_queue "local" do
		dequeue Async::Job::Processor::Inline
	end
end
