class MemberAttachment
  # require 'RMagick'

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'member_attachments'
  # MAXIMUM_IN_MEMBER = 10

  field :image
  field :name
  field :member_attachment_group_id

  mount_uploader :image, MemberAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create

	validates :image, file_size: {
		maximum: 10.megabytes
	}, on: :create

  # validate :check_maximum_in_member

  index({member_attachment_group_id: 1})

  # def check_maximum_in_member
  #   if MemberAttachment.where(member_attachment_group_id: self.member_attachment_group_id).count >= MAXIMUM_IN_MEMBER
  #     errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_MEMBER))
  #   end
  # end


  def self.delete_orphan
    MemberAttachment.where(:member_id => nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

end
