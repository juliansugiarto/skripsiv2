class Service

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in database: 'sribulancer_development', collection: 'services'
  TITLE_MINIMUM_LENGTH = 8
  TITLE_MAXIMUM_LENGTH = 100
  DESCRIPTION_MINIMUM_LENGTH = 100
  DESCRIPTION_MAXIMUM_LENGTH_SHOW = 3000
  DESCRIPTION_MAXIMUM_LENGTH = DESCRIPTION_MAXIMUM_LENGTH_SHOW + 2000
	DESCRIPTION_MAXIMUM_LENGTH_DB = 10000
  DELIVERABLES_MINIMUM_LENGTH = 10
  DELIVERABLES_MAXIMUM_LENGTH = 300
	DELIVERABLES_MAXIMUM_LENGTH_DB = 320

  field :title
  field :description
  field :budget, type: Float
  field :budget_in_idr, type: Float
  field :service_attachment_group_id
  field :service_photo_id
  field :slug
  field :deliverables
  field :approved, type: Boolean, default: false
  field :requested, type: Boolean, default: true
  field :status
  field :anonymous_id
  field :deleted_at, type: DateTime

  # FLAG
  field :fu, type: Boolean, default: false

  embeds_many :status_histories

  attr_accessor :online_group_category_id

  validates :title, presence: true, :length => { :minimum => TITLE_MINIMUM_LENGTH, :maximum => TITLE_MAXIMUM_LENGTH }
  validates :description, presence: true, :length => { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH_DB }
  validates :non_tags_description, length: { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH }
  validates :deliverables, presence: true, :length => { :minimum => DELIVERABLES_MINIMUM_LENGTH, :maximum => DELIVERABLES_MAXIMUM_LENGTH_DB }
  validates :online_category_id, presence: true
  validates :currency_id, presence: true
  validates :budget, presence: true
  validates :photo, presence: true, :unless => :member_for_testing?
  validate :budget_is_more_than_category_minimum

  belongs_to :member, :foreign_key => :member_id
  belongs_to :currency
  belongs_to :online_category, index: true

  has_many :orders, :class_name => "ServiceOrder"

  default_scope ->{ where(:member_id.exists => true) }
  scope :online_category_id, ->(category_id) { where(online_category_id: category_id) }
  scope :online_category_id_in, ->(category_ids) { any_in(online_category_id: category_ids) }
  scope :member_ids, ->(member_ids) { where(:member_id.in => member_ids) }
  scope :created_at_desc, -> {desc(:created_at)}
  scope :due_date_desc, -> {desc(:due_date)}
  scope :due_date_asc, -> {asc(:due_date)}
  scope :budget_desc, -> {desc(:budget_in_idr)}
  scope :budget_asc, -> {asc(:budget_in_idr)}
  scope :active_only, ->{ any_in(status: [Status::APPROVED, Status::CLOSED]) }
  scope :opened_only, -> { where(status: Status::APPROVED) }
  scope :closed, ->{ any_in(status: Status::CLOSED) }
  scope :closed_no_hired, ->{ where(:member_id.exists => false) }
  scope :closed_only, ->{ }
  scope :except_deleted, -> {where(:status.ne => Status::DELETED )}
  scope :except_draft, -> {where(:status.ne => Status::DRAFT )}
  scope :draft_only, -> {where(:status => Status::DRAFT )}
  scope :updated_at_desc, -> { desc(:updated_at) }
  before_save :set_budget_in_idr, :set_slug
  after_create :notify, :set_initial_state
  before_destroy :destroy_cb

  def non_tags_description
    return ActionView::Base.full_sanitizer.sanitize(self.description).to_s.gsub("&nbsp;", " ").gsub("&#39;", "'")
  end

  def budget_is_more_than_category_minimum
    if self.budget.blank? or self.online_category.blank? or self.currency.blank?
      # do nothing
    elsif !self.online_category.is_amount_more_than_minimum_budget(self.currency, self.budget, self)
      errors.add(:budget, I18n.t('services.new.label.budget_must_be_more_than_category_minimum', category: self.online_category.name_display, minimum_budget: self.online_category.minimum_budget_in_currency_display(self.currency)))
    end
  end

  def budget_in_currency_without_code(to_currency_code)
    convert_budget(to_currency_code)
  end

  def budget_display
    "#{self.currency.code} #{number_to_currency(self.budget, unit: '', precision: self.currency.precision_to_use)}"
  end

  def commision_fee_display
    "#{self.currency.code} #{number_to_currency(self.commision_fee, unit: '', precision: self.currency.precision_to_use)}"
  end

  def tax_fee_display
    "#{self.currency.code} #{number_to_currency(self.tax_fee, unit: '', precision: self.currency.precision_to_use)}"
  end

  def payout_before_tax_display
    "#{self.currency.code} #{number_to_currency(self.payout_before_tax, unit: '', precision: self.currency.precision_to_use)}"
  end

  def payout_after_tax_display
    "#{self.currency.code} #{number_to_currency(self.payout_after_tax, unit: '', precision: self.currency.precision_to_use)}"
  end


  def online_category_display
    self.online_category.name_display
  end

  def attachments
    ServiceAttachment.where(service_attachment_group_id: self.service_attachment_group_id)
  end

  def photo
    ServicePhoto.find_by(service_photo_id: self.service_photo_id)
  end

  # when created, service must be not be approved
  def set_initial_state
    # auto approve service if it's testing member
    if !self.member.blank? and self.member.for_testing?
      General::ChangeStatusService.new(self, Status::APPROVED).change
    # actually draft is already Status::DRAFT, but set it anyway to make sure and insert it to status histories
    elsif self.draft?
      General::ChangeStatusService.new(self, Status::DRAFT).change
    else
      General::ChangeStatusService.new(self, Status::REQUESTED).change
    end
    self.save
  end

  # approve this service and notify owner
  def approve(current_member)
    General::ChangeStatusService.new(self, Status::APPROVED, current_member).change
    if self.save
      MemberMailerWorker.perform_async(service_id: self.id.to_s, perform: :send_service_approval)

      KissmetricsWorker.perform_async(perform: :service_approved, identity: self.member.email, properties: self.km_properties_for_approved_service)
      return true
    end
    return false
  end

  # reject this service and notify owner
  def reject(current_member, reason='', send_mail=true)
    General::ChangeStatusService.new(self, Status::REJECTED, current_member, reason).change
    if self.save
      if send_mail
        MemberMailerWorker.perform_async(service_id: self.id.to_s, perform: :send_service_rejection)
      end
      return true
    else
      return false
    end
  end

  # properties to be pushed to kissmetric
  def km_properties
    {title: self.title, category: self.online_category.cname, online_group_category: self.online_category.online_group_category.cname, budget: self.budget_in_currency_without_code(Currency.get_idr.code)}
  end

  # properties for kissmetrics new job
  def km_properties_for_new_service
    km = self.km_properties
    km[:service_budget] = self.budget_in_currency_without_code(Currency.get_idr.code)
    km
  end

  # properties for kissmetrics new job
  def km_properties_for_approved_service
    km = self.km_properties
    km[:approved_service_budget] = self.budget_in_currency_without_code(Currency.get_idr.code)
    km
  end

  # check if service has a member or not
  def orphan?
    self.member.blank? ? true : false
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

  def deleted?
    # NOTE:
    # Don't use this line if we're still using Paranoia
    # self.status == Status::DELETED

    self.deleted_at.present?
  end

  def commision_fee
    self.budget * ((StaticDataLancer::SERVICE_ORDER_PERCENTAGE_FEE).to_f/100.to_f)
  end

  def tax_fee
    (self.budget - self.commision_fee) * ((StaticDataLancer::PPH_FEE).to_f/100.to_f)
  end

  def payout_before_tax
    self.budget - self.commision_fee
  end

  def payout_after_tax
    self.budget - self.commision_fee - self.tax_fee
  end

  # check if job is on draft status
  def draft?
    self.status == Status::DRAFT
  end

  # set job status to be draft, you still need to save it outside
  def set_status_draft
    General::ChangeStatusService.new(self, Status::DRAFT).change
  end

  # override getter for budget, if budget is blank then return 0
  def budget
    self[:budget].blank? ? 0 : self[:budget]
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

  # check if member owner of this service is for testing
  def member_for_testing?
    self.member.for_testing?
  end

  # get Service count by its categories in a group category
  # might be slow, only used in cache code
  def self.count_by_categories(online_group_category)
    services = Service.opened_only.online_category_id_in(online_group_category.online_category_ids)

    categories = Hash.new 0

    services.each do |service|
      categories[service.online_category_id.to_s] += 1
    end

    categories = categories.sort_by { |k, v| -v }
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

  def notify
    return if self.draft?

    TeamMailerWorker.perform_async(service_id: self.id.to_s, perform: :send_new_service)

    if !self.orphan?
      KissmetricsWorker.perform_async(perform: :new_service, identity: self.member.email, properties: self.km_properties_for_new_service)
    end
  end

  def set_budget_in_idr
    self.budget_in_idr = self.currency.convert_to_idr(self.budget)
  end

  def set_slug
    self.slug = "#{self.title.to_s.parameterize}-#{self.id}"
  end


  def destroy_cb
    General::ChangeStatusService.new(self, Status::DELETED).change

    # TODO:
    # self.save will call another callback
    # bad practice, anyone have solution for this ?
    self.save(validate: false)
  end

end
