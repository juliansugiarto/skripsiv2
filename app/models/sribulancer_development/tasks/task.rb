class Task
  include ActionView::Helpers::NumberHelper

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in database: 'sribulancer_development', collection: 'tasks'
  TITLE_MINIMUM_LENGTH = 8
  TITLE_MAXIMUM_LENGTH = 100
  DESCRIPTION_MINIMUM_LENGTH = 100
  DESCRIPTION_MAXIMUM_LENGTH_SHOW = 3000
  DESCRIPTION_MAXIMUM_LENGTH = DESCRIPTION_MAXIMUM_LENGTH_SHOW + 2000
  DESCRIPTION_MAXIMUM_LENGTH_DB = 10000

  field :title
  field :description
  field :slug
  field :approved, type: Boolean, default: false
  field :requested, type: Boolean, default: true
  field :status
  field :job_attachment_group_id
  field :anonymous_id
  field :deleted_at, type: DateTime
  field :first_notify, type: Boolean # Dipakai untuk kirim email ke employer apabila ada applicant pertama yang sudah apply.

  attr_accessor :offline_group_category_id

  embeds_many :status_histories
  
  belongs_to :service_provider_member, :foreign_key => :service_provider_member_id
  belongs_to :offline_category, index: true
  belongs_to :location
  belongs_to :currency
  belongs_to :member

  has_one :report_blast_email
  has_many :task_applications
  has_many :orders, :class_name => "TaskOrder"
  embeds_one :brief, :class_name => "TaskBrief"

  default_scope ->{ where(:member_id.exists => true) }

  scope :except_deleted, -> {where(:status.ne => Status::DELETED )}
  scope :created_at_desc, -> {desc(:created_at)}
  scope :updated_at_desc, -> {desc(:updated_ast)}
  scope :opened_only, -> { where(status: Status::APPROVED) }
  scope :closed_only, -> { where(:status.nin => [Status::REJECTED, Status::REQUESTED, Status::DRAFT]) }
  scope :active_only, ->{ any_in(status: [Status::APPROVED, Status::CLOSED]) }

  before_save :set_title, :set_slug
  after_create :set_initial_state, :notify
  after_destroy :destroy_cb

  def draft?
    self.status == Status::DRAFT
  end

  def orphan?
    self.member.blank? ? true : false
  end

  def non_tags_description
    return ActionView::Base.full_sanitizer.sanitize(self.description).to_s.gsub("&nbsp;", " ").gsub("&#39;", "'")
  end

  def name_seo_display
    self.name_seo[I18n.locale].parameterize
  end

  def set_initial_state
    if !self.member.blank? and self.member.for_testing?
      General::ChangeStatusService.new(self, Status::APPROVED).change
    # actually draft is already Status::DRAFT, but set it anyway to make sure and insert it to status histories
    elsif self.draft?
      General::ChangeStatusService.new(self, Status::DRAFT).change
    else
      General::ChangeStatusService.new(self, Status::REQUESTED).change
    end
    self.save(validate: false)
  end

  def still_open?
    self.approved?
  end
  
  def attachments
    JobAttachment.where(job_attachment_group_id: self.job_attachment_group_id)
  end

  def set_slug
    self.slug = "#{self.title.to_s.parameterize}-#{self.id}"
  end

  def set_title
    if self.title.blank?
      self.title = I18n.t("general.default_task_title", category: self.offline_category.name[I18n.locale], location: self.location.name)
    end
  end

  def offline_category_display
    offline_category.name_display
  end

  def notify
    MemberMailerWorker.perform_async(task_id: self.id.to_s, perform: :send_task_wait_for_approval)
  end

  def destroy_cb
    General::ChangeStatusService.new(self, Status::DELETED).change

    # TODO:
    # self.save will call another callback
    # bad practice, anyone have solution for this ?
    # no need validation
    self.save(validate: false)
  end

  def approve(current_member)
    General::ChangeStatusService.new(self, Status::APPROVED, current_member).change
    if self.save
      MemberMailerWorker.perform_async(task_id: self.id.to_s, perform: :send_task_approval)
      ServiceProviderMailerWorker.perform_async(company_category: self.offline_category.offline_group_category_id.to_s, task_id: self.id.to_s, perform: :send_recap_email_new_task_to_service_provider)
      # KissmetricsWorker.perform_async(perform: :job_approved, identity: self.member.email, properties: self.km_properties_for_approved_job)
      return true
    end
    return false
  end

  # reject this job and notify owner
  def reject(current_member, reason='', send_mail=true)
    General::ChangeStatusService.new(self, Status::REJECTED, current_member, reason).change

    if self.save
      # if send_mail == true
      #   MemberMailerWorker.perform_async(job_id: self.id.to_s, perform: :send_job_rejection)
      # end
      return true
    else
      return false
    end
  end

  def km_properties
    {title: self.title, offline_category: self.offline_category.cname, offline_group_category: self.offline_category.offline_group_category.cname}
  end
  
  def rejected?
    self.status == Status::REJECTED
  end

  def requested?
    self.status == Status::REQUESTED
  end

  def approved?
    self.status == Status::APPROVED
  end

end
