# represent an event where backoffice has released payout
class AdminReleasedPayoutEvent < WorkspaceStatusEvent

  CNAME = 'admin_released_payout_event'

  belongs_to :user

  field :payout_type

  field :paypal_email

  field :bank_id
  field :bank_name
  field :account_number
  field :account_name
  field :branch

  def display
    username = self.workspace.freelancer.present? ? self.workspace.freelancer.username : self.workspace.service_provider.username
    I18n.t("workspaces.events.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => username)
  end

  def awaiting
    username = self.workspace.freelancer.present? ? self.workspace.freelancer.username : self.workspace.service_provider.username
    I18n.t("workspaces.awaiting.#{CNAME}", :employer => self.workspace.employer.username, :freelancer => username)
  end

  # notify the other user in the workspace
  def notify
    receiver = self.workspace.freelancer || self.workspace.service_provider
    # disable temporarily to fix live data
    MemberMailerWorker.perform_async(member_id: receiver.id.to_s, workspace_id: self.workspace.id.to_s, status_event_id: self.id.to_s, perform: :send_payout_released_event)
  end

end
