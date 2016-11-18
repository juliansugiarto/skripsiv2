  # represent a job posted by employer member
class Recruitment

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in database: 'sribulancer_development', collection: 'recruitments'
  TITLE_MINIMUM_LENGTH = 8
  TITLE_MAXIMUM_LENGTH = 100
  DESCRIPTION_MINIMUM_LENGTH = 100
  DESCRIPTION_MAXIMUM_LENGTH_SHOW = 3000
  DESCRIPTION_MAXIMUM_LENGTH = DESCRIPTION_MAXIMUM_LENGTH_SHOW + 2000
	DESCRIPTION_MAXIMUM_LENGTH_DB = 10000

  field :title
  field :description
  field :due_date, type: DateTime
  field :slug
  field :attachment_group_id
  field :approved, type: Boolean, default: false
  field :requested, type: Boolean, default: true
  field :status

  field :anonymous_id
  field :deleted_at, type: DateTime

  # FLAG
  field :fu, type: Boolean, default: false
  field :first_notify, type: Boolean # Dipakai untuk kirim email ke employer apabila ada applicant pertama yang sudah apply.

  field :blast_email_to_freelancer, type: Boolean, default: false # Untuk blast ke freelancer sekali saja

  # Demographic Recruitment Job
  field :qualification
  field :gender

  attr_accessor :company_name
  attr_accessor :company_profile
  attr_accessor :company_overview

  embeds_many :status_histories

  validates :title, presence: true, :length => { :minimum => TITLE_MINIMUM_LENGTH, :maximum => TITLE_MAXIMUM_LENGTH }
  validates :description, presence: true, :length => { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH_DB }
  validates :non_tags_description, length: { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH }
  validates :due_date, presence: true
  validates :recruitment_category_id, presence: true
  validates :industry_id, presence: true

  belongs_to :member, :foreign_key => :member_id
  belongs_to :recruitment_category
  belongs_to :industry
  belongs_to :qualification

  has_one :report_blast_email
  has_many :recruitment_applications
  has_and_belongs_to_many :skills, inverse_of: nil
  has_and_belongs_to_many :locations, inverse_of: nil

  default_scope ->{ where(:member_id.exists => true) }

  scope :recruitment_category_id, ->(recruitment_category_id) { where(recruitment_category_id: recruitment_category_id) }
  scope :member_ids, ->(member_ids) { where(:member_id.in => member_ids) }
  scope :created_at_desc, -> {desc(:created_at)}
  scope :due_date_desc, -> {desc(:due_date)}
  scope :due_date_asc, -> {asc(:due_date)}
  scope :active_only, ->{ any_in(status: [Status::APPROVED, Status::CLOSED]) }
  scope :opened_only, -> { where(:due_date.gt => DateTime.now, status: Status::APPROVED) }
  # Change this scope to Status::DELETED if it's implemented.
  scope :closed_only, -> { where(:due_date.lt => DateTime.now, :status.nin => [Status::REJECTED, Status::REQUESTED]) }
  scope :not_deleted, -> {where(:status.ne => Status::DELETED)}
  scope :closed, -> { where(:member_id.exists => true) }
  scope :closed_no_hired, -> { where(:member_id.exists => false) }

  before_save :set_slug
  after_create :notify, :set_initial_state
  before_destroy :destroy_cb

  def non_tags_description
    if self.description.present?
      return ActionView::Base.full_sanitizer.sanitize(self.description).to_s.gsub("&nbsp;", " ").gsub("&#39;", "'")
    else
      return ""
    end
  end

  def online_category_display
    self.recruitment_category.name_display
  end

  def online_category
    self.recruitment_category
  end

  # when created, recruitment must be not be approved
  def set_initial_state
    if !self.member.blank? and self.member.for_testing?
      General::ChangeStatusService.new(self, Status::APPROVED).change
    else
      General::ChangeStatusService.new(self, Status::REQUESTED).change
    end
    self.save
  end

  # approve this recruitment and notify owner
  def approve(current_member)
    General::ChangeStatusService.new(self, Status::APPROVED).change
    if self.save
      MemberMailerWorker.perform_async(recruitment_id: self.id.to_s, perform: :send_recruitment_approval)

      # Send email blast to freelancer about new job
      # broadcast_to_all_freelancers(current_member) if self.blast_email_to_freelancer == false

      # Create recap dialy for new job (send email blast everyday at 8.30 am)
      recap_daily_for_new_recruitment(current_member) if self.blast_email_to_freelancer == false

      properties = {title: self.title, online_category: self.online_category.cname}
      KissmetricsWorker.perform_async(perform: :recruitment_approved, identity: self.member.email, properties: properties)
      return true
    end
    return false
  end

  # reject this recruitment and notify owner
  def reject
    General::ChangeStatusService.new(self, Status::REJECTED).change
    if self.save
      MemberMailerWorker.perform_async(recruitment_id: self.id.to_s, perform: :send_recruitment_rejection)
      return true
    end
    return false
  end

  # check if recruitment has a member or not
  def orphan?
    self.member.blank? ? true : false
  end

  # Check if recruitment still open
  def still_open?
    DateTime.now < self.due_date
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

  def closed?
    # NOTE:
    # Don't use this line if we're still using Paranoia
    # self.status == Status::CLOSED

    DateTime.now > self.due_date
  end

  # check if recruitment has deleted
  def deleted?
    # NOTE:
    # Don't use this line if we're still using Paranoia
    # self.status == Status::DELETED

    self.deleted_at.present?
  end  

  def has_one_workspace_completed?
    self.orders.each do |o|
      return true if !o.workspace.blank? and o.workspace.completed?
    end
    return false
  end



  def skill_tokens=(arg)
    # WHAT: Inserting skill.id instead of skill object.
    # REASON: Because mongoid will save all changes even though it doesn't pass our validation.
    # REPRODUCE: 
    # m = Member.last
    # m.skills = [] # member will being save @mongoid-4.0.0
    skill_list = Array.new
    arg ||= ""
    
    arg.split(',').each do |skill_id|
      skill = SkillLancer.find(skill_id)
      skill_list << skill.id if skill.present?
    end
    self.skill_ids = skill_list
  end

  def skill_tokens
    self.skills.collect { |s| "#{s.id}:#{s.name}" }.join(',')
  end

  # Hanya display skill dengan bootstrap label
  def skills_display_label
    ret = ''

    ret = "<strong>" + I18n.t('jobs.new.label.required_skills') + ":</strong><br>" if self.skills.any?
    self.skills.each do |s|
      ret += "<span class='label label-default mr-5'>#{s.name}</span>"
    end

    return ret
  end


  def location_tokens=(arg)
    location_list = Array.new
    arg.split(',').each do |location_id|
      location = Location.find(location_id)
      location_list << location.id if location.present?
    end
    self.location_ids = location_list
  end

  def location_tokens
    self.locations.collect { |s| "#{s.id}:#{s.name}" }.join(',')
  end


  private

  # This method is disable since March 2015
  # broadcast this recruitment to all freelancers
  def broadcast_to_all_freelancers(current_member)
    freelancers = FreelancerMember.where(email_validation_key: nil, email_notif_new_recruitment: true, disabled: false)
    freelancers = freelancers.any_in(recruitment_category_ids: self.recruitment_category.id)

    freelancers.each do |fm|
      MemberMailerWorker.perform_async(member_id: fm.id.to_s, recruitment_id: self.id.to_s, perform: :send_new_recruitment_to_freelancer)
    end

    self.update_attribute(:blast_email_to_freelancer, true)
    ReportBlastEmail.new(:recruitment => self, :user => current_member, :total_recipients => freelancers.size, :context => ReportBlastEmail::CONTEXT_BLAST_NEW_RECRUITMENT).save
  end

  # Create recap daily new recruitment for freelancer
  def recap_daily_for_new_recruitment(current_member)
    freelancers = FreelancerMember.where(email_validation_key: nil, email_notif_new_recruitment: true, disabled: false)
    freelancers = freelancers.any_in(recruitment_category_ids: self.recruitment_category.id)

    freelancers.each do |fm|
      if fm.recap_daily.blank?
        fm.recap_daily = RecapDaily.create(member_type: fm._type)
      end
      fm.recap_daily.recap_daily_lists.create(type: 'Recruitment', recruitment_id: self.id)
    end

    self.update_attribute(:blast_email_to_freelancer, true)
    ReportBlastEmail.new(:recruitment => self, :user => current_member, :total_recipients => freelancers.size, :context => ReportBlastEmail::CONTEXT_BLAST_NEW_RECRUITMENT).save
  end

  def notify

    if !self.orphan?
      TeamMailerWorker.perform_async(recruitment_id: self.id.to_s, perform: :send_new_recruitment)
      properties = {title: self.title, online_category: self.online_category.cname}
      KissmetricsWorker.perform_async(perform: :new_recruitment, identity: self.member.email, properties: properties)
    end
  end

  def set_slug
    self.slug = "#{self.title.to_s.parameterize}-#{self.id}"
  end

  def destroy_cb
    General::ChangeStatusService.new(self, Status::DELETED).change

    # TODO:
    # self.save will call another callback
    # bad practice, anyone have solution for this ?
    self.save
  end

  def self.test
    Job.opened_only.each do |j|
      EmployerMailerWorker.perform_async(job_id: j.id.to_s, perform: :send_daily_application_list)
    end
  end

end
