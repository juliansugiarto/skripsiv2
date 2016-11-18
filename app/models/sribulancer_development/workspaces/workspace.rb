# represent a job posted by employer member
class Workspace

  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails.application.routes.url_helpers
  store_in database: 'sribulancer_development', collection: 'workspaces'
  MINIMUM_ACTIVITY_BEFORE_CLOSING = 3

  # =====================================
  # DENORMALIZED
  # Be careful with these field.
  # =====================================
  field :employer_username
  field :freelancer_username
  field :service_provider_username
  field :zn_payment_code

  # custom profit is denormalized field
  # this field will follow current freelancer custom_profit value
  field :custom_profit

  # Recording last activity for each user
  field :employer_last_activity, :type => DateTime
  field :freelancer_last_activity, :type => DateTime
  field :service_provider_last_activity, :type => DateTime

  embeds_many :events, class_name: 'WorkspaceEvent'

  scope :created_at_desc, -> {desc(:created_at)}

  after_create :initialise_status

  has_many :member_reviews
  has_many :freelancer_reviews
  has_many :employer_reviews

  # Sesuai dengan yang ada di *.yml
  def status_display
    self.events.reject{|e| !(e.is_a? WorkspaceStatusEvent)}.last.display
  end

  # Return object
  def status
    self.events.reject{|e| !(e.is_a? WorkspaceStatusEvent)}.last
  end

  # Untuk backoffice, e.g: Progress, RequestPayout, Completed
  def status_backoffice(html=true)
    # Memorization, so we're not searching it again.
    if self.started?
      return (html ? "<span class='label label-warning'>Progress</span>".html_safe : 1)
    elsif self.closed?
      return (html ? "<span class='label label-info'>Closed</span>".html_safe : 2)
    elsif self.payout_requested?
      return (html ? "<span class='label label-danger'>Payout Req</span>".html_safe : 3)
    elsif self.payout_released?
      return (html ? "<span class='label label-success'>Payout Released</span>".html_safe : 4)
    elsif self.canceled_by_admin?
      return (html ? "<span class='label label-primary'><a href='#{cancel_admin_workspace_path(self.id)}' data-toggle='modal' data-target='#remote_modal'>Canceled by Admin</a></span>".html_safe : 0)
    elsif self.refunded_by_admin?
      return (html ? "<span class='label label-default'>Refunded by Admin</span>".html_safe : 0)
    end
  end

  def last_status
    if self.started?
      return 'progress'
    elsif self.closed?
      return 'closed'
    elsif self.payout_requested?
      return 'request_payout'
    elsif self.payout_released?
      return 'release_payout'
    elsif self.canceled_by_admin?
      return 'canceled_by_admin'
    elsif self.refunded_by_admin?
      return 'refunded_by_Admin'
    end
  end

  def activity_alert(w)
    if w.alert?
        return "  <span class='label label-danger'>Alert</span>".html_safe
    end
  end

  def alert_freelancer
    if self.freelancer_last_activity.present? and self.started?
      if ((Time.now - self.freelancer_last_activity) / 86400).to_i > 4
        if self.freelancer.present?
          freelancer_fun = self.freelancer.follow_up.follow_up_notes.find_by(type: 'Workspace', workspace_id: self.id, :status.nin => [Status::FU_1, Status::FU_2, Status::FU_3]) if self.freelancer.follow_up.present?
        end
        if freelancer_fun.present?
          if ((Time.now - freelancer_fun.created_at) / 86400).to_i > 4
            return true
          else
            return false
          end
        else
          return true
        end
      else
        return false
      end
    else
      return false
    end
  end

  def alert_employer
    if self.employer_last_activity.present? and self.started?
      if ((Time.now - self.employer_last_activity) / 86400).to_i > 4
        if self.employer.present?
          employer_fun = self.employer.follow_up.follow_up_notes.find_by(type: 'Workspace', workspace_id: self.id, :status.nin => [Status::FU_1, Status::FU_2, Status::FU_3]) if self.employer.follow_up.present?
        end
        if employer_fun.present?
          if ((Time.now - employer_fun.created_at) / 86400).to_i > 4
            return true
          else
            return false
          end
        else
          return true
        end
      else
        return false
      end
    else
      return false
    end
  end

  def alert?
    self.alert_freelancer or self.alert_employer
  end

  def member_fu?
    employer_fun = self.employer.follow_up.follow_up_notes.find_by(type: 'Workspace', workspace_id: self.id) if self.employer.follow_up.present?
    freelancer_fun = self.freelancer.follow_up.follow_up_notes.find_by(type: 'Workspace', workspace_id: self.id) if self.freelancer.present? and self.freelancer.follow_up.present?
    service_provider_fun = self.service_provider.follow_up.follow_up_notes.find_by(type: 'Workspace', workspace_id: self.id) if self.service_provider.present? and self.service_provider.follow_up.present?
    employer_fun.present? or freelancer_fun.present? or service_provider_fun.present?
  end

  # Untuk front end freelance's profile page
  def status_profile
    s = self.status
    if s.class == EmployerInitiatedJobEvent or s.class == EmployerInitiatedServiceEvent or s.class == EmployerInitiatedPackageEvent
      return "<span class='label label-warning'>On Going</span>".html_safe
    else
      return "<span class='label label-success'>Completed</span>".html_safe
    end
  end

  def non_status_events
    self.events.reject{|e| (e.is_a? WorkspaceStatusEvent)}
  end

  # count how many unread message by a member in this workspace
  def message_unread_count(member_to_check)
    self.events.where(read: false).nin(member_id: [member_to_check.id] ).count
  end

  # check if this workspace is started
  def started?
    (self.status.is_a? EmployerInitiatedJobEvent) or (self.status.is_a? EmployerInitiatedServiceEvent) or (self.status.is_a? EmployerInitiatedTaskEvent) or (self.status.is_a? EmployerInitiatedPackageEvent)
  end

  # check if this workspace is completed
  def completed?
    (self.status.is_a? EmployerClosedJobEvent) or (self.status.is_a? FreelancerRequestedPayoutEvent) or (self.status.is_a? ServiceProviderRequestedPayoutEvent) or (self.status.is_a? AdminReleasedPayoutEvent) or (self.status.is_a? EmployerClosedTaskEvent) or (self.status.is_a? AdminRefundedEvent)
  end

  def closed?
    self.status.is_a? EmployerClosedJobEvent or self.status.is_a? EmployerClosedServiceEvent or self.status.is_a? EmployerClosedTaskEvent
  end
  # check if this workspace payment has been requested
  def payout_requested?
    self.status.is_a? FreelancerRequestedPayoutEvent or self.status.is_a? ServiceProviderRequestedPayoutEvent
  end

  # check if this workspace payment has been released
  def payout_released?
    self.status.is_a? AdminReleasedPayoutEvent
  end

  # check if this workspace is cancelled by Admin
  def canceled_by_admin?
    self.status.is_a? AdminCanceledEvent
  end

  def refunded_by_admin?
    self.status.is_a? AdminRefundedEvent
  end

  # title of the project
  def title
    raise NotImplementedError
  end

  # order of the project
  def order
    raise NotImplementedError
  end

  def is_participant? (member)
    (member.username == self.employer_username) || (member.username == self.freelancer_username)
  end

  def other_member(member)
    if member.username == employer_username
      if self.is_a? TaskWorkspace
        MemberLancer.find_by(username: service_provider_username)
      else
        MemberLancer.find_by(username: freelancer_username)
      end
    else
      if member.class == User
        MemberLancer.find_by(username: freelancer_username)
      else
        MemberLancer.find_by(username: employer_username)
      end
    end
  end

  def get_last_chat_at(member)
    a = self.events.desc(:created_at).select {|e| (e.is_a? MessageEvent) and (e.member==member)}.first
    return (a.present?) ? a.created_at.strftime('%d %b %Y - %H:%M') : "-"
  end

  def get_type
    if self.is_a? TaskWorkspace
      self.task
    elsif self.is_a? JobWorkspace
      self.job
    elsif self.is_a? ServiceWorkspace
      self.service
    elsif self.is_a? PackageWorkspace
      self.package
    end
  end

  # to prevent no method error, will be overriden on child class
  def freelancer
  end

  def service_provider
  end
end
