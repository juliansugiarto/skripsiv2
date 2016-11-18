class JobAttachment
  # require 'RMagick'
  extend Unscoped
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'job_attachments'
  MAXIMUM_IN_JOB = 15

  belongs_to :job

  field :image
  field :name
  field :job_attachment_group_id

  unscope :job

  mount_uploader :image, JobAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create

	validates :image, file_size: {
		maximum: 10.megabytes
	}, on: :create
  
  validate :check_maximum_in_job

  index({job_attachment_group_id: 1})

  def check_maximum_in_job
    if JobAttachment.where(job_attachment_group_id: self.job_attachment_group_id).count >= MAXIMUM_IN_JOB
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_JOB))
    end
  end


  def self.delete_orphan
    JobAttachment.where(:job_id => nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

end
