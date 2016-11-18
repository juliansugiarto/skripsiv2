# represent a job posted by employer member
class Job

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in database: 'sribulancer_development', collection: 'jobs'

  TITLE_MINIMUM_LENGTH = 8
  TITLE_MAXIMUM_LENGTH = 100
  DESCRIPTION_MINIMUM_LENGTH = 100
  DESCRIPTION_MAXIMUM_LENGTH_SHOW = 3000
  DESCRIPTION_MAXIMUM_LENGTH = DESCRIPTION_MAXIMUM_LENGTH_SHOW + 2000
	DESCRIPTION_MAXIMUM_LENGTH_DB = 10000

  field :title
  field :description
  field :due_date, type: DateTime
  field :budget, type: Float
  field :budget_in_idr, type: Float
  field :job_attachment_group_id
  field :slug
  field :approved, type: Boolean, default: false
  field :requested, type: Boolean, default: true
  field :status
  field :anonymous_id
  field :deleted_at, type: DateTime
  field :private, type: Boolean, default: false

  # FLAG
  field :fu, type: Boolean, default: false
  field :first_notify, type: Boolean # Dipakai untuk kirim email ke employer apabila ada applicant pertama yang sudah apply.

  field :blast_email_to_freelancer, type: Boolean, default: false # Untuk blast ke freelancer sekali saja

  field :zn_job_application_count, default: 0

  embeds_many :status_histories

  attr_accessor :online_group_category_id

  index({slug: 1}, { unique: true})
  index({online_category_id: 1})
  index({member_id: 1})

  validates :title, presence: true, length: { :minimum => TITLE_MINIMUM_LENGTH, :maximum => TITLE_MAXIMUM_LENGTH }
  validates :description, presence: true, length: { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH_DB }
  validates :non_tags_description, length: { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH }
  validates :due_date, presence: true, :unless => :private?
  validates :online_category_id, presence: true
  validates :currency_id, presence: true
  validates :budget, presence: true, numericality: {greater_than: 0}

  belongs_to :member, :foreign_key => :member_id
  belongs_to :currency
  belongs_to :online_category, index: true
  belongs_to :zn_first_completed_job_order, :class_name => "JobOrder", inverse_of: nil

  alias_method :active_record_category, :online_category

  has_one :report_blast_email
  has_many :job_applications
  has_many :job_offers
  has_many :orders, :class_name => "JobOrder"
  has_many :chats

  has_and_belongs_to_many :skills, inverse_of: nil

  default_scope ->{ where(:member_id.exists => true) }
  scope :online_category_id, ->(category_id) { where(online_category_id: category_id) }
  scope :online_category_id_in, ->(category_ids) { any_in(online_category_id: category_ids) }
  scope :member_ids, ->(member_ids) { where(:member_id.in => member_ids) }
  scope :created_at_desc, -> {desc(:created_at)}
  scope :updated_at_desc, -> {desc(:updated_at)}
  scope :due_date_desc, -> {desc(:due_date)}
  scope :due_date_asc, -> {asc(:due_date)}
  scope :budget_desc, -> {desc(:budget_in_idr)}
  scope :budget_asc, -> {asc(:budget_in_idr)}
  scope :except_closed, ->{ any_in(status: [StatusLancer::REJECTED, StatusLancer::REQUESTED, StatusLancer::APPROVED], private: false).where(:due_date.gt => DateTime.now) }
  scope :active_only, ->{ any_in(status: [StatusLancer::APPROVED, StatusLancer::CLOSED], private: false) }

  scope :opened_only, -> { where(:due_date.gt => DateTime.now, status: StatusLancer::APPROVED, private: false) }
  scope :except_deleted, -> {where(:status.ne => StatusLancer::DELETED )}
  scope :draft_only, -> {where(:status => StatusLancer::DRAFT)}

  # Change this scope to StatusLancer::DELETED if it's implemented.
  scope :closed_only, -> { where(:due_date.lt => DateTime.now, :status.nin => [StatusLancer::REJECTED, StatusLancer::REQUESTED, StatusLancer::DRAFT]) }
  scope :private_only, -> {where(private: true)}
  scope :public_only, -> {where(private: false)}
  scope :not_deleted, -> {where(:status.ne => StatusLancer::DELETED )}
  scope :unapproved, -> {where(:member_id.exists => true, :deleted_at => nil, status: StatusLancer::REQUESTED, private: false)}

  # Closed job that marked as no hired freelancer by admin, so they wouldn't follow up anymore
  scope :marked_no_hired_only, -> { where(:due_date.lt => DateTime.now, status: StatusLancer::NO_HIRED ) }
  scope :due_date_between, ->(start_period, end_period) { where(:due_date.gt => start_period, :due_date.lte => end_period) }

  order_paid_ids = Order.where(order_status_id: OrderStatus.get_paid).distinct(:job_id)
  scope :closed, -> { any_in(_id: order_paid_ids ).where(:due_date.lt => DateTime.now) }
  scope :closed_no_hired, ->  {where(:_id.nin => order_paid_ids, :due_date.lt => DateTime.now) }
  scope :paid, -> {where(:id.in => order_paid_ids)}
  scope :paid_by_date, -> (from, to) {where(:id.in => Order.where(order_status_id: OrderStatus.get_paid, paid_at: from..to).distinct(:job_id))}

  # Used in Browse Jobs -> Sorting Dropdown

  scope :ending_soon, ->{ opened_only.due_date_asc }
  scope :new_job, ->{ opened_only.created_at_desc }
  scope :highest_paid, -> { opened_only.desc(:budget_in_idr) }
  scope :popular, ->{ opened_only.desc(:zn_job_application_count) }
  scope :low_participant, ->{ opened_only.asc(:zn_job_application_count) }

  # Pakai class completed saja, soalnya querynya lebih bisa dimainkan.
  # scope :completed, -> { opened_only.any_in(_id: order_paid_ids).created_at_desc }

  scope :paid_by_date, -> (from, to) {where(:id.in => Order.where(order_status_id: OrderStatus.get_paid, paid_at: from..to).distinct(:job_id))}

  before_save :set_budget_in_idr, :set_slug
  after_create :notify, :set_initial_state
  before_destroy :destroy_cb

  def non_tags_description
    return ActionView::Base.full_sanitizer.sanitize(self.description).to_s.gsub("&nbsp;", " ").gsub("&#39;", "'")
  end

  # # only allow numbers to be set on budget
  # def budget=(budget)
  #   write_attribute(:budget, budget.gsub(/\D/, ''))
  #   # write_attribute(:budget, budget.to_f)
  # end

  # check if budget is more than category minimum
  def budget_is_more_than_category_minimum
    if self.budget.blank? or self.online_category.blank? or self.currency.blank?
      # do nothing
    elsif !self.online_category.is_amount_more_than_minimum_budget(self.currency, self.budget, self)
      errors.add(:budget, I18n.t('jobs.new.label.budget_must_be_more_than_category_minimum', category: self.online_category.name_display, minimum_budget: self.online_category.minimum_budget_in_currency_display(self.currency)))
    end
  end

  # if category is blank return null category
  # google about Null Object Pattern
  def online_category
    self.active_record_category || OnlineCategory.new
  end

  def budget_in_currency_without_code(to_currency_code)
    convert_budget(to_currency_code)
  end

  def budget_display
    "#{self.currency.code} #{number_to_currency(self.budget, unit: '', precision: self.currency.precision_to_use)}"
  end

  def budget_payout_display
    "#{self.currency.code} #{number_to_currency(self.budget_payout, unit: '', precision: self.currency.precision_to_use)}"
  end

  def online_category_display
    self.online_category.name_display
  end

  def attachments
    JobAttachment.where(job_attachment_group_id: self.job_attachment_group_id)
  end

  def status_display
    if self.deleted?
      status = 'danger'
      name = 'deleted'
    elsif self.closed?
      status = 'default'
      name = 'closed'
    elsif self.approved?
      status = 'success'
      name = 'approved'
    elsif self.requested?
      status = 'info'
      name = 'requested'
    elsif self.rejected?
      status = 'warning'
      name = 'rejected'
    end

    return (status.present? ? "<span class='label label-#{status}'>#{name.titleize}</span>".html_safe : "Orphan")
  end

  # when created, job must be not be approved
  def set_initial_state
    if !self.member.blank? and self.member.for_testing?
      General::ChangeStatusService.new(self, StatusLancer::APPROVED).change
    # actually draft is already StatusLancer::DRAFT, but set it anyway to make sure and insert it to status histories
    elsif self.draft?
      General::ChangeStatusService.new(self, StatusLancer::DRAFT).change
    else
      General::ChangeStatusService.new(self, StatusLancer::REQUESTED).change
    end
    self.save(validate: false)
  end

  # approve this job and notify owner
  def approve(current_member)
    General::ChangeStatusService.new(self, StatusLancer::APPROVED, current_member).change
    if self.save
      # if privete, broadcast to freelancers that had been offered this job
      if self.private?
        MemberMailerWorker.perform_async(job_id: self.id.to_s, perform: :send_private_job_approval)

        # notify all freelancer that has been offered this job
        if self.private?
          self.job_offers.each do |jo|
            jo.notify
          end
        end

        KissmetricsWorker.perform_async(perform: :job_approved, identity: self.member.email, properties: self.km_properties_for_approved_job)
        return true
      else
        # Send email to employer that job was approved
        MemberMailerWorker.perform_async(job_id: self.id.to_s, perform: :send_job_approval)

        # Send email blast to freelancer about new job
        # broadcast_to_all_freelancers(current_member) if self.blast_email_to_freelancer == false

        if self.blast_email_to_freelancer == false
          # Create recap dialy for new job (send email blast everyday at 8.30 am)
          BackofficeWorker.perform_async(
            job_id: self.id.to_s,
            admin_user_id: current_member.id.to_s,
            perform: :recap_daily_for_new_job)
        end

        KissmetricsWorker.perform_async(perform: :job_approved, identity: self.member.email, properties: self.km_properties_for_approved_job)
        return true
      end
    end
    return false
  end

  # reject this job and notify owner
  def reject(current_member, reason='', send_mail=true)
    General::ChangeStatusService.new(self, StatusLancer::REJECTED, current_member, reason).change

    if self.save
      if send_mail == true
        if self.private?
          MemberMailerWorker.perform_async(job_id: self.id.to_s, perform: :send_private_job_rejection)
        else
          MemberMailerWorker.perform_async(job_id: self.id.to_s, perform: :send_job_rejection)
        end
      end
      return true
    else
      return false
    end

  end

  # check if given job application already hired
  def is_applicant_hired?(job_application)
    self.orders.each do |order|
      return true if order.job_application == job_application and order.initiated?
    end

    return false
  end

  # check if job has a member or not
  def orphan?
    self.member.blank? ? true : false
  end

  def still_open?
    return true if self.private?
    DateTime.now < self.due_date
  end

  def rejected?
    self.status == StatusLancer::REJECTED
  end

  def requested?
    self.status == StatusLancer::REQUESTED
  end

  def approved?
    self.status == StatusLancer::APPROVED
  end

  def active?
    self.approved? and (self.private? or DateTime.now < self.due_date)
  end

  def no_hired?
    self.status == StatusLancer::NO_HIRED
  end

  def closed?
    # NOTE:
    # Don't use this line if we're still using Paranoia
    # self.status == StatusLancer::CLOSED
    return false if self.private?
    DateTime.now > self.due_date
  end

  def deleted?
    # NOTE:
    # Don't use this line if we're still using Paranoia
    # self.status == StatusLancer::DELETED

    self.deleted_at.present?
  end

  def has_one_workspace_completed?
    self.orders.each do |o|
      return true if !o.workspace.blank? and o.workspace.completed?
    end
    return false
  end

  def budget_payout
    return "0" if self.budget.nil?
    self.budget * ((100-StaticDataLancer::JOB_ORDER_PERCENTAGE_FEE).to_f/100.to_f)
  end

  def payout_after_tax
    self.budget_payout * ((100-StaticDataLancer::PPH_FEE).to_f/100.to_f)
  end

  def payout_after_tax_display
    "#{self.currency.code} #{number_to_currency(self.payout_after_tax, unit: '', precision: self.currency.precision_to_use)}"
  end

  # notify to all freelancers that employer has not hired and they can start looking for other jobs
  def notify_no_hiring
    self.job_applications.each do |ja|
      MemberMailerWorker.perform_async(member_id: ja.member.id.to_s, job_id: self.id.to_s, perform: :send_no_hiring_to_freelancer)
    end
  end


  def notify_employer_to_check_applicants
    if self.job_applications.size > 0
      EmployerMailerWorker.perform_async(member_id: self.member.id.to_s, job_id: self.id.to_s, perform: :send_notify_employer_to_check_applicants)
    end
  end

  # get Job count by its categories in a group category
  # might be slow, only used in cache code
  def self.count_by_categories(online_group_category)
    return nil if online_group_category.blank?
    jobs = Job.opened_only.online_category_id_in(online_group_category.online_category_ids)

    categories = Hash.new 0

    jobs.each do |job|
      categories[job.online_category_id.to_s] += 1
    end

    categories = categories.sort_by { |k, v| -v }
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
  # Lain kegunaan nya dengan job_helper#show_required_skills
  def skills_display_label
    ret = ''

    ret = "<p class='iblocks mr-5'>" + I18n.t('jobs.new.label.required_skills') + ":</p> " if self.skills.any?
    self.skills.each do |s|
      ret += "<span class='label label-default label-flat mr-5'>#{s.name}</span>"
    end

    return ret
  end


  def blacklist?
    # Ini job buatan internal untuk testing. Belum dipake dulu.
    blacklist_array = ["53c7a7c2616e7469da040000"]

    if blacklist_array.include? self.id.to_s
      return true
    else
      return false
    end
  end

  # properties to be pushed to kissmetric
  def km_properties
    if self.private?
      {
        title: self.title,
        budget: self.budget_in_currency_without_code(Currency.get_idr.code)
      }
    else
      {
        title: self.title,
        online_category: (self.online_category.present?) ? self.online_category.cname : nil,
        online_group_category: (self.online_category.present?) ? self.online_category.online_group_category.cname : nil,
        budget: self.budget_in_currency_without_code(Currency.get_idr.code)
      }
    end
  end

  # properties for kissmetrics new job
  def km_properties_for_new_job
    km = self.km_properties
    km[:job_budget] = self.budget_in_currency_without_code(Currency.get_idr.code)
    km
  end

  # properties for kissmetrics new job
  def km_properties_for_approved_job
    km = self.km_properties
    km[:approved_job_budget] = self.budget_in_currency_without_code(Currency.get_idr.code)
    km
  end

  # list of all recipients to this job offer with link to their profile
  def recipients
    result = Array.new
    JobOffer.where(job: self).each do |jo|
      result << jo.member
    end
    result
  end

  # check if some fields in job already specified
  def not_empty?
    if !self.title.blank? or !self.description.blank? or !self.budget.blank?
      true
    else
      false
    end
  end

  def notify
    if !self.orphan? and !self.draft?

      # If job private (direct hiring), skip this send email
      # Because when direct hiring, we no need to approve the new job
      if !self.private?
        MemberMailerWorker.perform_async(job_id: self.id.to_s, perform: :send_new_job_to_employer)
      end

      KissmetricsWorker.perform_async(perform: :new_job, identity: self.member.email, properties: self.km_properties_for_new_job)
    end
  end

  # output title for draft, because might not have a title yet
  def draft_title
    if self.draft?
      if self.title.empty?
        return I18n.t('jobs.new.modal_job_draft.no_title')
      else
        return self.title
      end
    end
  end

  # # override getter for budget, if budget is blank then return 0
  # def budget
  #   self[:budget].blank? ? 0 : self[:budget]
  # end

  # check if job is on draft status
  def draft?
    self.status == StatusLancer::DRAFT
  end

  # set job status to be draft, you still need to save it outside
  def set_status_draft
    General::ChangeStatusService.new(self, StatusLancer::DRAFT).change
  end

  def self.completed
    return where(:zn_first_completed_job_order.exists => true).created_at_desc
  end


  private

  def convert_budget(to_currency_code)
    result = 0
    if Currency.where(code: to_currency_code).any?
      to_currency = Currency.where(code: to_currency_code).first
      if self.currency == to_currency
        result = self.budget
      else
        result = self.currency.convert_to_currency(to_currency, self.budget)
      end
    else
      result = self.budget
    end
    result
  end

  # This method is disable since March 2015
  # broadcast this job to all freelancers
  def broadcast_to_all_freelancers(current_member)
    # Kalau ini berdasarkan "group category" -> skills yang diassign pertama kali ke group category secara default dari awal
    # skills = self.online_category.online_group_category.skills.map(&:id)

    # Sesuai job's skill(s) yang di set
    skills = self.skills.map(&:id)
    freelancers = FreelancerMember.where(email_validation_key: nil, email_notif_new_job: true, disabled: false)
    freelancers = freelancers.any_in(skill_ids: skills)

    freelancers.each do |fm|
      MemberMailerWorker.perform_in(10.minutes, member_id: fm.id.to_s, job_id: self.id.to_s, perform: :send_new_job_to_freelancer)
    end

    self.update_attribute(:blast_email_to_freelancer, true)

    ReportBlastEmail.new(:job => self, :user => current_member, :total_recipients => freelancers.size, :context => ReportBlastEmail::CONTEXT_BLAST_NEW_JOB).save
  end


  def set_budget_in_idr
    budget = self.budget.present? ? self.budget : 0
    self.budget_in_idr = self.currency.convert_to_idr(budget)
  end

  def set_slug
    self.slug = "#{self.title.to_s.parameterize}-#{self.id}"
  end

  def destroy_cb
    General::ChangeStatusService.new(self, StatusLancer::DELETED).change

    # TODO:
    # self.save will call another callback
    # bad practice, anyone have solution for this ?
    # no need validation
    self.save(validate: false)
  end

  def self.test
    Job.opened_only.each do |j|
      EmployerMailerWorker.perform_async(job_id: j.id.to_s, perform: :send_daily_application_list)
    end
  end

  # if employer does not decide 3 days after job closed, then notify all freelancers
  def self.send_employer_not_hiring_to_freelancers

    # find jobs that has been closed for 3 days
    start_period = DateTime.now - 4.days
    end_period = DateTime.now - 3.days

    Job.due_date_between(start_period, end_period).each do |j|
      # Do not send email if job have orders or status is no_hired
      next if !j.orders.paid.blank? or j.status == StatusLancer::NO_HIRED
      j.notify_no_hiring
    end
  end


  def self.send_email_to_employer_when_job_due_date
    start_period = ((DateTime.now - 1.days).beginning_of_day - 1.second)
    end_period = DateTime.now.beginning_of_day

    Job.due_date_between(start_period, end_period).where(:status => StatusLancer::APPROVED).each do |j|

      # If employer already hire freelancer, skip send email
      next if j.orders.present?
      j.notify_employer_to_check_applicants

    end
  end

end
