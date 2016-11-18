class JobApplicationAttachment
  # require 'RMagick'
  
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'job_application_attachments'
  MAXIMUM_IN_JOB_APPLICATION = 5

  field :image
  field :name
  field :job_application_attachment_group_id

  mount_uploader :image, JobApplicationAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create
  validates :job_application_attachment_group_id, :presence => true, :on => :create

	validates :image, file_size: {
		maximum: 10.megabytes
	}, on: :create
  
  validate :check_maximum_in_job

  index({job_application_attachment_group_id: 1})

  def check_maximum_in_job
    if JobApplicationAttachment.where(job_application_attachment_group_id: self.job_application_attachment_group_id).count >= MAXIMUM_IN_JOB_APPLICATION
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_JOB_APPLICATION))
    end
  end


  def self.delete_orphan
    JobApplicationAttachment.where(:job_application_id => nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

end
