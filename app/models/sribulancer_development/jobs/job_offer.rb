# represent a job offer from employer to freelancer
class JobOffer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'job_offers'
  field :is_rejected, type: Boolean, default: false

  validates :member, presence: true, :uniqueness => {:scope => [:job_id]}
  validates :job, presence: true

  belongs_to :member
  belongs_to :job
  belongs_to :job_application

  scope :created_at_desc, -> {desc(:created_at)}

  def not_applied_yet?
    self.job_application.blank?
  end

end
