# Accept last bid
class ChatBidRejectEvent < ChatEvent

  include Mongoid::Document
  include Mongoid::Timestamps

  CNAME = 'chat_bid_reject_event'

  HIDE_BY_ADMIN = 'admin'
  HIDE_BY_USER = 'user'

  field :message, type: Float
  field :read, default: false
  field :inbound, default: false # True when created from mandrill inbound email
  field :hide

  belongs_to :member

  validates :message, presence: true
  validates :message, numericality: { only_integer: false }

  # notify the other user in the workspace
  def notify
    sender = self.member
    receiver = self.find_receiver_from_sender_chat(sender)

    # we don't send email to online user
    # if receiver.last_activity.blank? or (receiver.last_activity < (DateTime.now - 10.minutes))
    MemberMailerWorker.perform_async(member_id: receiver.id.to_s, chat_id: self.chat.id.to_s, chat_message_event_id: self.id.to_s, perform: :send_chat_message_event)
    # end
  end

  def message
    (!self.member.blank? and self.member.disabled?) ? "Content marked as spam by Admin" : self[:message]
  end

  def bid_budget
    # Default currency code if not exist
    currency = (self.chat.currency.present?) ? self.chat.currency : Currency.find_by(code: 'IDR')
    "#{currency.code} #{number_to_currency(self.message, unit: '', precision: 0, delimiter: '.')}"
  end
end
