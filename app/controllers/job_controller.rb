class JobController < ApplicationController
  def index
    @job_executions = JobExecution.all
  end

  def execute
    job = MyJob

    if queue = params[:queue]
      job = job.set(queue: queue)
    end

    job.perform_later(queued_to: queue)
  end
end
