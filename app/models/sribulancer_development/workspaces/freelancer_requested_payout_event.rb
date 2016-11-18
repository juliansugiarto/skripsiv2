# represent a job posted by employer member
class FreelancerRequestedPayoutEvent < WorkspaceStatusEvent

  CNAME = 'freelancer_requested_payout_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => self.workspace.freelancer.username)
  end

end
