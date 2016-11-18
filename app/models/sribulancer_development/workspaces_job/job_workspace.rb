class JobWorkspace < Workspace

  belongs_to :job_order

  index({job_order_id: 1})

  def employer
    self.job_order.job.member if self.job_order.present?
  end

  def freelancer
    self.job_order.job_application.member if self.job_order.present?
  end

  def job
    self.job_order.job if self.job_order.present?
  end

  def order
    self.job_order
  end

  def title
    self.job_order.job.title
  end

  def job_application
    self.job_order.job_application
  end

  def initialise_status
    employer_initiated_job_event = EmployerInitiatedJobEvent.new
    employer_initiated_job_event.member = self.employer

    self.events << employer_initiated_job_event
    self.save
  end

end
