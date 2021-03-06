# represent a job posted by employer member
class EmployerInitiatedJobEvent < WorkspaceStatusEvent

  CNAME = 'employer_initiated_job_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end

  def awaiting
  end

  def notify
    # do nothing
  end
  
end
