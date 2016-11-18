# represent a job posted by employer member
class EmployerInitiatedTaskEvent < WorkspaceStatusEvent

  CNAME = 'employer_initiated_task_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :service_provider => self.workspace.service_provider.username)
  end

  def awaiting
  end
  
  def notify
    # do nothing
  end
  
end
