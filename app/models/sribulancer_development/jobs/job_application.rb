# represent a job posted by employer member
class JobApplication
  extend Unscoped

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper
  
  include Mongoid::Document
  include Mongoid::Timestamps

  include Elasticsearch::Model
  include Elasticsearch::Model::Serializing
  include Elasticsearch::Model::Callbacks
  store_in database: 'sribulancer_development', collection: 'job_applications'

  REASON_MINIMUM_LENGTH = 20
  REASON_MAXIMUM_LENGTH_SHOW = 1000
  REASON_MAXIMUM_LENGTH = REASON_MAXIMUM_LENGTH_SHOW + 1000
  REASON_MAXIMUM_LENGTH_DB = 3000

  field :reason
  field :job_application_attachment_group_id
  field :status_selection
  field :budget, type: Float
  field :zn_job_private, type: Boolean, default: false

  validates :reason, presence: true, :length => { :minimum => REASON_MINIMUM_LENGTH, :maximum => REASON_MAXIMUM_LENGTH_DB }
  validates :non_tags_reason, length: { :minimum => REASON_MINIMUM_LENGTH, :maximum => REASON_MAXIMUM_LENGTH }
  validates :budget, presence: true

  belongs_to :member
  belongs_to :job
  belongs_to :currency

  has_many :orders, :class_name => "JobOrder"

  after_create :notify, :update_job_offer
  before_create :set_currency

  scope :created_at_desc, -> {desc(:created_at)}
  scope :favourite, -> { where(status_selection: Status::FAVOURITED) }
  scope :eliminated, -> { where(status_selection: Status::ELIMINATED) }
  scope :not_eliminated, -> { where(:status_selection.ne => Status::ELIMINATED) }

  unscope :job

  index({member_id: 1})
  index({job_id: 1})

  def non_tags_reason
    return ActionView::Base.full_sanitizer.sanitize(self.reason).to_s.gsub(/[\r\n\t]/, '')
  end

  def job_application_attachments
    JobApplicationAttachment.where(job_application_attachment_group_id: self.job_application_attachment_group_id) if self.job_application_attachment_group_id.present?
  end
  
  def budget_display
    "#{self.currency.code} #{number_to_currency(self.budget, unit: '', precision: self.currency.precision_to_use)}" if self.currency.present?
  end

  # notify employer of this new applicant
  def notify
    if self.job.first_notify.present?
      self.job.unset(:first_notify)
      MemberMailerWorker.perform_async(member_id: self.job.member.id.to_s, job_application_id: self.id.to_s, perform: :send_new_job_application)
    end
  end

  def favourited?
    self.status_selection == Status::FAVOURITED
  end

  def eliminated?
    self.status_selection == Status::ELIMINATED
  end

  def reason
    (!self.member.blank? and self.member.disabled?) ? "Content marked as spam by Admin" : self[:reason]
  end

  # update job offer if this job application is from job offer
  def update_job_offer
    jo = JobOffer.find_by(member: self.member, job: self.job)
    
    unless jo.blank?
      jo.job_application = self
      jo.save
    end
  end

  # Save all match skills in elasticsearch
  def matched_skill
    text = ''
    counter = 0.0
    skills = self.member.skills
    
    if self.job.present?
      self.job.skills.each do |s|
        if skills.include? s
          text += "<span class='mb-5 label label-info'>#{s.name}</span>"
          counter += 1
        end
      end

      if counter > 0
        percent = (counter/self.job.skills.count*100).to_i 
      else
        percent = 0
      end
    end

    return { percent: percent, text: text }
  end

  def as_indexed_json(options={})
    self.as_json(
      except: [:id, :_id],
      methods: [:job_application_attachments, :matched_skill],
      include: {
        member: {
          except: [:id, :_id],
          methods: [:reviews_avg, :attachments],
          include: {
            prefered_languages: {
              only: [:name]
            },
            country: {
              only: [:name]
            },
            educations: {
              except: [:_id]
            },
            employments: {
              except: [:_id]
            }
          }
        }
      }
    )
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :percent, type: 'long'
    end
  end

  private

  # always follow job currency
  # applicant can only make bid in job currency
  def set_currency
    self.currency = self.job.currency
  end

end
