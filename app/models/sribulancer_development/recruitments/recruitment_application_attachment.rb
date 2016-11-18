class RecruitmentApplicationAttachment
  # require 'RMagick'
  
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'recruitment_application_attachments'
  MAXIMUM_IN_RECRUITMENT_APPLICATION = 5

  field :image
  field :name
  field :attachment_group_id

  mount_uploader :image, RecruitmentApplicationAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create

	validates :image, file_size: {
		maximum: 10.megabytes
	}, on: :create
  
  validate :check_maximum_in_recruitment

  def check_maximum_in_recruitment
    if RecruitmentApplicationAttachment.where(attachment_group_id: self.attachment_group_id).count >= MAXIMUM_IN_RECRUITMENT_APPLICATION
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_RECRUITMENT_APPLICATION))
    end
  end


  def self.delete_orphan
    RecruitmentApplicationAttachment.where(:recruitment_application_id => nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

end
