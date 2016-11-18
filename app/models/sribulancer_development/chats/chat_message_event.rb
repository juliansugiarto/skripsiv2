# represent a job posted by employer member
class ChatMessageEvent < ChatEvent

  include Mongoid::Document
  include Mongoid::Timestamps

  CNAME = 'chat_message_event'
  MESSAGE_MINIMUM_LENGTH = 5
  MESSAGE_MAXIMUM_LENGTH = 3000
  
  HIDE_BY_ADMIN = 'admin'
  HIDE_BY_USER = 'user'

  field :message
  field :attachment_group_id
  field :read, default: false
  field :inbound, default: false # True when created from mandrill inbound email
  field :hide

  belongs_to :member

  validates :message, presence: true
  validates :messages, length: { :minimum => MESSAGE_MINIMUM_LENGTH, :maximum => MESSAGE_MAXIMUM_LENGTH }

  def attachments
    ChatMessageEventAttachment.where(attachment_group_id: self.attachment_group_id)
  end

  # notify the other user in the workspace
  def notify
    sender = self.member
    receiver = self.find_receiver_from_sender_chat(sender)

    # we don't send email to online user
    # if receiver.last_activity.blank? or (receiver.last_activity < (DateTime.now - 10.minutes))
    if receiver.email_notif_new_chat?
      MemberMailerWorker.perform_async(member_id: receiver.id.to_s, chat_id: self.chat.id.to_s, chat_message_event_id: self.id.to_s, perform: :send_chat_message_event)
    end
    # end
  end

  def message
    (!self.member.blank? and self.member.disabled?) ? "Content marked as spam by Admin" : self[:message]
  end

end
