class TaskWorkspace < Workspace

  belongs_to :task_order

  def employer
    self.task_order.task.member
  end

  def service_provider
    self.task_order.task_application.member
  end

  def task
    self.task_order.task if self.task_order.present?
  end

  def order
    self.task_order
  end

  def title
    self.task_order.task.title
  end

  def task_application 
    self.task_order.task_application
  end

  def initialise_status
    employer_initiated_task_event = EmployerInitiatedTaskEvent.new
    employer_initiated_task_event.member = self.employer

    self.events << employer_initiated_task_event
    self.save
  end

end
