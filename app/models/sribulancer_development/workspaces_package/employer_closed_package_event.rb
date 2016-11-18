# represent a job posted by employer member
class EmployerClosedPackageEvent < WorkspaceStatusEvent

  CNAME = 'employer_closed_package_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end
  
end
