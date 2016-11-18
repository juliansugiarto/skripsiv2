# represent a service posted by employer member
class EmployerClosedServiceEvent < WorkspaceStatusEvent

  CNAME = 'employer_closed_service_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end
  
end
