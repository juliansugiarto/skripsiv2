# represent a service posted by employer member
class EmployerClosedTaskEvent < WorkspaceStatusEvent

  CNAME = 'employer_closed_task_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :service_provider => self.workspace.service_provider.username)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}", :employer => self.workspace.employer.username, :service_provider => self.workspace.service_provider.username)
  end
  
end
