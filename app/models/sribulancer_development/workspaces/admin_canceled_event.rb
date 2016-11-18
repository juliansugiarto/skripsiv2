# represent an event where backoffice has released payout
class AdminCanceledEvent < WorkspaceStatusEvent

  CNAME = 'admin_canceled_event'

  belongs_to :user

  field :reason
  field :subtitute_freelancer

  def display
    I18n.t("workspaces.events.#{CNAME}", :email => StaticDataLancer::TEAM_EMAIL)
  end

  def awaiting
    I18n.t("workspaces.awaiting.#{CNAME}")
  end

  # notify the other user in the workspace
  def notify
    # do nothing
  end

end
