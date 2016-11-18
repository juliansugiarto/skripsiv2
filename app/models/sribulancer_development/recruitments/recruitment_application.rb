# represent a job posted by employer member
class RecruitmentApplication
  extend Unscoped
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'recruitment_applications'
  REASON_MINIMUM_LENGTH = 20
  REASON_MAXIMUM_LENGTH_SHOW = 400
  REASON_MAXIMUM_LENGTH = REASON_MAXIMUM_LENGTH_SHOW + 1000
  REASON_MAXIMUM_LENGTH_DB = 3000

  field :reason
  field :attachment_group_id
  field :status_selection

  validates :reason, presence: true, :length => { :minimum => REASON_MINIMUM_LENGTH, :maximum => REASON_MAXIMUM_LENGTH_DB }
  validates :non_tags_reason, length: { :minimum => REASON_MINIMUM_LENGTH, :maximum => REASON_MAXIMUM_LENGTH }

  belongs_to :member
  belongs_to :recruitment

  after_create :notify

  scope :created_at_desc, -> {desc(:created_at)}
  scope :favourite, -> { where(status_selection: StatusLancer::FAVOURITED) }
  scope :eliminated, -> { where(status_selection: StatusLancer::ELIMINATED) }
  scope :not_eliminated, -> { where(:status_selection.ne => StatusLancer::ELIMINATED) }

  unscope :recruitment

  def non_tags_reason
    return ActionView::Base.full_sanitizer.sanitize(self.reason).to_s.gsub(/[\r\n\t]/, '')
  end

  def recruitment_application_attachments
    RecruitmentApplicationAttachment.where(attachment_group_id: self.attachment_group_id)
  end

  # notify employer of this new applicant
  def notify
    if self.recruitment.first_notify.present?
      self.recruitment.unset(:first_notify)
      MemberMailerWorker.perform_async(member_id: self.recruitment.member.id.to_s, recruitment_application_id: self.id.to_s, perform: :send_new_recruitment_application)
      TeamMailerWorker.perform_async(recruitment_application_id: self.id.to_s, perform: :send_new_recruitment_application)
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

end
