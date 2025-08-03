class MyJob < ApplicationJob
  queue_as "default"

  def perform(*arguments, **options)
    if delay = options[:delay]
      # Sleep for the specified delay (in seconds) before creating the record:
      sleep(delay)
    end
    
    JobExecution.create!(name: self.class.name, data: {
      arguments: arguments,
      **options,
    })
  end
end
