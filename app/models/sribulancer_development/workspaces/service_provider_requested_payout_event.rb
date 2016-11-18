# represent a job posted by employer member
class ServiceProviderRequestedPayoutEvent < WorkspaceStatusEvent

  CNAME = 'service_provider_requested_payout_event'

  belongs_to :member

  def display
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :service_provider => self.workspace.service_provider.username)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}", :employer => self.workspace.employer.username, :service_provider => self.workspace.service_provider.username)
  end

end
