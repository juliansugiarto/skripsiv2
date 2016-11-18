# represent a chat for a pair of user
class ChatLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'chats'
  # =====================================
  # DENORMALIZED
  # Be careful with these field.
  # =====================================
  field :employer_username
  field :freelancer_username
  field :service_provider_username

  field :employer_archive, default: false
  field :freelancer_archive, default: false
  field :freelancer_archive_deleted, default: false
  field :employer_archive_deleted, default: false
  field :service_provider_archive, default: false

  belongs_to :employer, :class_name => 'EmployerMember', :foreign_key => :employer_id
  belongs_to :freelancer, :class_name => 'FreelancerMember', :foreign_key => :freelancer_id
  belongs_to :service_provider, :class_name => 'ServiceProviderMember', :foreign_key => :service_provider_id
  belongs_to :recruitment
  belongs_to :job
  belongs_to :service
  belongs_to :task

  # Di pakai ketika employer init chat ke freelancer @job_application
  # DI gunakan untuk bidding @chat/show
  belongs_to :currency

  embeds_many :events, class_name: 'ChatEvent'

  validates :employer_id, :uniqueness => { :scope => [:freelancer_id, :recruitment_id] }, :if => :from_recruitment?
  validates :employer_id, :uniqueness => { :scope => [:freelancer_id, :job_id] }, :if => :from_job?
  validates :employer_id, :uniqueness => { :scope => [:service_provider_id, :task_id] }, :if => :from_task?

  scope :recruitment_type, -> {where(:recruitment_id.ne => "", :recruitment_id.exists => true)}
  scope :job_type, -> {where(:job_id.ne => "", :job_id.exists => true)}
  scope :task_type, -> {where(:task_id.ne => "", :task_id.exists => true)}
  scope :service_type, -> {where(:service_id.ne => "", :service_id.exists => true)}
  scope :updated_at_desc, -> {desc(:updated_at)}

  index({employer_id: 1})
  index({freelancer_id: 1})
  index({job_id: 1})

  # check if this chat is from recruitment
  def from_recruitment?
    if self.recruitment.blank?
      false
    else
      true
    end
  end

  # check if this chat is from job
  def from_job?
    if self.job.blank?
      false
    else
      true
    end
  end

  def from_task?
    if self.task.blank?
      false
    else
      true
    end
  end

  # check if this chat is from service
  def from_service?
    if self.service.blank?
      false
    else
      true
    end
  end

  def other_member(member)
    if member == self.freelancer || member == self.service_provider
      self.employer
    else
      if from_task?
        self.service_provider
      else
        self.freelancer
      end
    end
  end

  def unread_count(member)
    self.events.in(:"_type" => ["ChatMessageEvent", "ChatBidEvent", "ChatBidAcceptEvent"]).where(read: false).nin(member_id: [member.id]).count
  end

  def is_participant? (member)
    (member.username == self.employer_username) || (member.username == self.freelancer_username)
  end

  #########################
  # KHUSUS UNTUK BIDDING
  #########################

  def last_event
    self.events.last
  end

  def last_message
    self.events.select{|e| (e.is_a? ChatMessageEvent)}.last
  end

  def last_bid
    # We take last bid from bid event and bid accept event
    if chat_bid = self.events.select{|e| (e.is_a? ChatBidEvent) or (e.is_a? ChatBidAcceptEvent)} and chat_bid.present?
      last_bid = chat_bid.last
    else
      return nil
    end
  end

  # to check who the last bidder
  def last_bid_is_from(member)
    if self.last_bid.present?
      self.last_bid.member == member
    else
      false
    end
  end

  # To check last bid is accepted or not
  def is_last_bid_accepted?
    self.events.select{|e| (e.is_a? ChatBidAcceptEvent)}.present?
  end

  # to get last bidding value.
  def last_bid_value
    if last_bid = self.last_bid
      last_bid.message
    else
      0
    end
  end

  def reject_offer?
    self.events.select{|e| (e.is_a? ChatBidRejectEvent)}.present?
  end

  def reject_offer_date
    e = self.events.select{|e| (e.is_a? ChatBidRejectEvent)}
    return e.first.created_at
  end

  # NOTE:
  # JANGAN TAMPILKAN TOMBOL REKRUT
  #   - Jika Employer sudah pernah chat dengan Freelancer dan bidding terakhir dari Employer
  #     , karena masih giliran Freelancer untuk menyetujui bidding terbaru dari Employer.
  # TAMPILKAN TOMBOL REKRUT
  #   - Employer belum pernah Chat dengan Freelancer ini.
  #   - Employer sudah chat, dan bidding terakhir dari Freelancer.
  #
  ### SEMENTARA KHUSUS JOB
  def self.is_eligible_for_recruitment?(job, employer, freelancer)
    if c = self.find_by(job: job, employer: employer, freelancer: freelancer)
      if c.last_bid_is_from(employer)
        eligible_to_recruit = false
      else
        eligible_to_recruit = true
      end
    else
      eligible_to_recruit = true
    end

    return eligible_to_recruit
  end

  # For task
  def self.is_task_chat_eligible_for_recruitment?(task, employer, service_provider)
    if c = self.find_by(task: task, employer: employer, service_provider: service_provider)
      if c.last_bid_is_from(employer)
        eligible_to_recruit = false
      else
        eligible_to_recruit = true
      end
    else
      eligible_to_recruit = true
    end

    return eligible_to_recruit
  end

end
