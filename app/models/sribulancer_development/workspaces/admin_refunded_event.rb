class AdminRefundedEvent < WorkspaceStatusEvent

  CNAME = 'admin_refunded_event'

  belongs_to :user
  field :reason

  def display
    I18n.t("workspaces.events.#{CNAME}", :email => StaticDataLancer::TEAM_EMAIL)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}")
  end

  def notify
    receiver_employer = self.workspace.employer
    MemberMailerWorker.perform_async(member_id: receiver_employer.id.to_s, workspace_id: self.workspace.id.to_s, status_event_id: self.id.to_s, perform: :send_admin_refunded_event_to_employer)

    receiver_freelancer = self.workspace.freelancer
    MemberMailerWorker.perform_async(member_id: receiver_freelancer.id.to_s, workspace_id: self.workspace.id.to_s, status_event_id: self.id.to_s, perform: :send_admin_refunded_event_to_freelancer)
  end

end
