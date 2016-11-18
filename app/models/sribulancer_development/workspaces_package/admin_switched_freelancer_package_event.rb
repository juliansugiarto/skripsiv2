# represent an event where backoffice has released payout
class AdminSwitchedFreelancerPackageEvent < WorkspaceEvent

  CNAME = 'admin_switched_freelancer_package_event'

  field :reason
  belongs_to :user
  belongs_to :prev_freelancer, :class_name => 'FreelancerMember'
  belongs_to :new_freelancer, :class_name => 'FreelancerMember'

  def display
    I18n.t("workspaces.events.#{CNAME}", :prev_freelancer => self.prev_freelancer.username, :new_freelancer => self.new_freelancer.username)
  end

  def notify
    receiver_employer = self.workspace.employer
    MemberMailerWorker.perform_async(member_id: receiver_employer.id.to_s, workspace_id: self.workspace.id.to_s, event_id: self.id.to_s, perform: :send_admin_switched_freelancer_package_event_to_employer)

    receiver_freelancer = self.workspace.freelancer
    MemberMailerWorker.perform_async(member_id: receiver_freelancer.id.to_s, workspace_id: self.workspace.id.to_s, event_id: self.id.to_s, perform: :send_admin_switched_freelancer_package_event_to_freelancer)

    receiver_prev_freelancer = self.workspace.prev_freelancer
    MemberMailerWorker.perform_async(member_id: receiver_prev_freelancer.id.to_s, workspace_id: self.workspace.id.to_s, event_id: self.id.to_s, perform: :send_admin_switched_freelancer_package_event_to_prev_freelancer)

    routes = Rails.application.routes.url_helpers
    bitly_url = Api::BitlyService.new.short_it(routes.workspace_url(self.new_freelancer.locale.to_s, self.workspace))
    ZenzivaWorker.perform_async(perform: :send_sms, to: self.new_freelancer.contact_number, text: I18n.t('sms.freelancer.you_got_package_order', :employer_name => self.workspace.employer.username, :url => bitly_url))
  end

end
