class ChatMessageEventAttachmentLancer
  require 'RMagick'
  
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in database: 'sribulancer_development', collection: 'chat_message_event_attachments'
  MAXIMUM_IN_MESSAGE = 5

  belongs_to :chat_message_event

  field :image
  field :name
  field :attachment_group_id

  mount_uploader :image, ChatMessageEventAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create

	validates :image, file_size: {
		maximum: 10.megabytes
	}, on: :create
  
  validate :check_maximum_in_message

  index({attachment_group_id: 1})

  def check_maximum_in_message
    if ChatMessageEventAttachment.where(attachment_group_id: self.attachment_group_id).count >= MAXIMUM_IN_MESSAGE
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_MESSAGE))
    end
  end


  def self.delete_orphan
    ChatMessageEventAttachment.where(:message_event_id => nil, :created_at.lte => 7.days.ago).each do |mea|
      mea.destroy
    end
  end

end
