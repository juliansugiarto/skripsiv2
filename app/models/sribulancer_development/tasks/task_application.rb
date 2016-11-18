# represent a job posted by employer member
class TaskApplication
  extend Unscoped

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper
  
  include Mongoid::Document
  include Mongoid::Timestamps

  REASON_MINIMUM_LENGTH = 20
  REASON_MAXIMUM_LENGTH_SHOW = 1000
  REASON_MAXIMUM_LENGTH = REASON_MAXIMUM_LENGTH_SHOW + 1000
  REASON_MAXIMUM_LENGTH_DB = 3000

  field :reason
  field :job_application_attachment_group_id
  field :status_selection
  field :budget, type: Float

  validates :reason, presence: true, :length => { :minimum => REASON_MINIMUM_LENGTH, :maximum => REASON_MAXIMUM_LENGTH_DB }
  validates :non_tags_reason, length: { :minimum => REASON_MINIMUM_LENGTH, :maximum => REASON_MAXIMUM_LENGTH }
  validates :budget, presence: true

  belongs_to :member
  belongs_to :task
  belongs_to :currency

  has_many :orders, :class_name => "TaskOrder"

  after_create :notify
  before_create :set_currency

  scope :created_at_desc, -> {desc(:created_at)}
  scope :favourite, -> { where(status_selection: StatusLancer::FAVOURITED) }
  scope :eliminated, -> { where(status_selection: StatusLancer::ELIMINATED) }
  scope :not_eliminated, -> { where(:status_selection.ne => StatusLancer::ELIMINATED) }

  unscope :task

  def non_tags_reason
    return ActionView::Base.full_sanitizer.sanitize(self.reason).to_s.gsub(/[\r\n\t]/, '')
  end

  def budget_display
    "#{self.currency.code} #{number_to_currency(self.budget, unit: '', precision: self.currency.precision_to_use)}" if self.currency.present?
  end

  def job_application_attachments
    JobApplicationAttachment.where(job_application_attachment_group_id: self.job_application_attachment_group_id)
  end

  # notify employer of this new applicant
  def notify
    if self.task.first_notify.present?
      self.task.unset(:first_notify)
      MemberMailerWorker.perform_async(member_id: self.task.member.id.to_s, task_application_id: self.id.to_s, perform: :send_new_task_application)
      TeamMailerWorker.perform_async(task_application_id: self.id.to_s, perform: :send_new_task_application)
    end
  end

  def favourited?
    self.status_selection == StatusLancer::FAVOURITED
  end

  def eliminated?
    self.status_selection == StatusLancer::ELIMINATED
  end

  def reason
    (!self.member.blank? and self.member.disabled?) ? "Content marked as spam by Admin" : self[:reason]
  end

  private

  # always follow job currency
  # applicant can only make bid in job currency
  def set_currency
    self.currency = self.task.currency
  end

end
