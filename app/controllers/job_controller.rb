class JobController < ApplicationController
  def index
    @job_executions = JobExecution.all
  end

  def execute
    job = MyJob

    if queue = params[:queue]
      job = job.set(queue: queue)
    end

    delay = params[:delay].to_i if params[:delay].present?
    job.perform_later(queued_to: queue, delay: delay)
  end
end
