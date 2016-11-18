# represent a job posted by employer member
class MessageEvent < WorkspaceEvent

  include Mongoid::Document
  include Mongoid::Timestamps

  CNAME = 'message_event'
  MESSAGE_MINIMUM_LENGTH = 5
  MESSAGE_MAXIMUM_LENGTH_SHOW = 1000
  MESSAGE_MAXIMUM_LENGTH = MESSAGE_MAXIMUM_LENGTH_SHOW + 2000
  MESSAGE_MAXIMUM_LENGTH_DB = 10000

  field :message
  field :message_event_attachment_group_id
  field :read, default: false
  field :inbound, default: false # True when created from mandrill inbound email
  # Record last notified via email
  field :notified_at, type: DateTime

  belongs_to :member

  validates :message, presence: true
  validates :messages, length: { :minimum => MESSAGE_MINIMUM_LENGTH, :maximum => MESSAGE_MAXIMUM_LENGTH }

  def attachments
    MessageEventAttachment.where(message_event_attachment_group_id: self.message_event_attachment_group_id)
  end

  # notify the other user in the workspace
  def notify
    sender = self.member
    receiver = find_receiver_from_sender_chat(sender)

    if receiver.present?
      # we don't send email to online user
      # if receiver.last_activity < (DateTime.now - 3.minutes)
      MemberMailerWorker.perform_async(member_id: receiver.id.to_s, workspace_id: self.workspace.id.to_s, message_event_id: self.id.to_s, perform: :send_message_event)
      # end
    end
    
  end

  def message
    (!self.member.blank? and self.member.disabled?) ? "Content marked as spam by Admin" : self[:message]
  end
end
