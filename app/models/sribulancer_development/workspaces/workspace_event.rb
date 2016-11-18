# represent a job posted by employer member
class WorkspaceEvent

  include Mongoid::Document
  include Mongoid::Timestamps

  HIDE_BY_ADMIN = 'admin'
  HIDE_BY_USER = 'user'

  field :hide
  
  embedded_in :workspace

  has_many :message_event_attachments

  after_create :notify


  def cname
    self.class::CNAME
  end

  def notify
    # do nothing, to be implemented by child classes
  end

  def messages
    return ActionView::Base.full_sanitizer.sanitize(self.message).to_s.gsub(/[\r\n\t]/, '').gsub("&nbsp;", " ").gsub("&#39;", "'")
  end

  def find_receiver_from_sender_chat(sender)
    if sender.is_a? FreelancerMember or sender.is_a? ServiceProviderMember 
      self.workspace.employer
    elsif sender.is_a? EmployerMember
      if self.workspace.is_a? TaskWorkspace
        self.workspace.service_provider
      else
        self.workspace.freelancer
      end
    end

  end

end
