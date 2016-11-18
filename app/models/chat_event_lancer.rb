# represent a job posted by employer member
class ChatEvent

  include Mongoid::Document
  include Mongoid::Timestamps

  include ActionView::Helpers

  # Record last notified via email
  field :notified_at, type: DateTime
  
  embedded_in :chat

  has_many :chat_message_event_attachments

  after_create :notify

  after_save do
    self.chat.touch
  end

  def cname
    self.class::CNAME
  end

  def notify
    # do nothing, to be implemented by child classes
  end

  def messages
    if self.message.class == String
      return ActionView::Base.full_sanitizer.sanitize(self.message).to_s.gsub(/[\r\n\t]/, '').gsub("&nbsp;", " ").gsub("&#39;", "'")
    else
      return self.message.to_s
    end
  end

  def find_receiver_from_sender_chat(sender)
     (self.chat.service_provider || self.chat.freelancer) == sender ? self.chat.employer : self.chat.from_task? ? self.chat.service_provider : self.chat.freelancer
  end

end
