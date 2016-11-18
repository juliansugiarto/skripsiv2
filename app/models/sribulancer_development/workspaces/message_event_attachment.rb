class MessageEventAttachment
  # require 'RMagick'
  
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'message_event_attachments'
  MAXIMUM_IN_MESSAGE = 5

  belongs_to :message_event

  field :image
  field :name
  field :message_event_attachment_group_id

  mount_uploader :image, MessageEventAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create

	validates :image, file_size: {
		maximum: 20.megabytes
	}, on: :create
  
  validate :check_maximum_in_message

  index({message_event_attachment_group_id: 1})

  def check_maximum_in_message
    if MessageEventAttachment.where(message_event_attachment_group_id: self.message_event_attachment_group_id).count >= MAXIMUM_IN_MESSAGE
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_MESSAGE))
    end
  end


  def self.delete_orphan
    MessageEventAttachment.where(:message_event_id => nil, :created_at.lte => 7.days.ago).each do |mea|
      mea.destroy
    end
  end

end
