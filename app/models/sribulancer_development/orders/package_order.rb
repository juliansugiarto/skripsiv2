# represent a package order by employer member
class PackageOrder < Order
  extend Unscoped

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  DESCRIPTION_MINIMUM_LENGTH = 100
  DESCRIPTION_MAXIMUM_LENGTH = 3000
  VOFFICE = 'voffice'

  # store leads info if it's orphen package order (anonymous)
  field :name
  field :contact_number
  field :description
  field :package_order_attachment_group_id
  field :freelancer_fee, type: Float, default: 0
  field :budget, type: Float, default: 0
  field :invoice_sent, type: Boolean, default: false
  field :affiliate_fee, type: Float, default: 0
  field :affiliate

  belongs_to :currency
  belongs_to :package
  belongs_to :employer, :class_name => 'EmployerMember'
  belongs_to :freelancer, :class_name => 'FreelancerMember'
  belongs_to :prev_freelancer, :class_name => 'FreelancerMember'

  has_one :package_workspace

  validates :budget, presence: true
  validates :package, presence: true
  validates :description, length: { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH }, :if => :not_new_record?

  after_create :notify

  def attachments
    PackageOrderAttachment.where(package_order_attachment_group_id: self.package_order_attachment_group_id)
  end

  def not_new_record?
    !self.new_record?
  end

  def mark_as_paid
    self.set_status_paid
    self.save(validate: false)

    MemberMailerWorker.perform_async(member_id: self.employer.id.to_s, package_order_id: self.id.to_s, perform: :send_package_paid_to_employer)
    TeamMailerWorker.perform_async(package_order_id: self.id.to_s, perform: :send_package_order_paid)

    if self.package.is_smm?
      InfusionsoftWorker.perform_async(employer_id: self.employer.id.to_s, perform: :buy_smm_package_paid)
    elsif self.package.is_ecomm?
      InfusionsoftWorker.perform_async(employer_id: self.employer.id.to_s, perform: :buy_ecomm_package_paid)
    elsif self.package.is_article?
      InfusionsoftWorker.perform_async(employer_id: self.employer.id.to_s, perform: :buy_article_package_paid)
    end
  end

  def assign_freelancer(freelancer_id)
    freelancer = FreelancerMember.find(freelancer_id)
    self.freelancer = freelancer
    self.requester_id = freelancer_id
    self.requester_username = freelancer.username
    self.requester_email = freelancer.email
    self.save(validate: false)
  end

  def can_create_workspace?
    self.package_workspace.blank? and !self.freelancer.blank?
  end

  def create_workspace
    return unless self.package_workspace.blank?

    self.package_workspace = PackageWorkspace.new(employer_username: self.employer.username, freelancer_username: self.freelancer.username, zn_payment_code: self.payment_code)

    self.package_workspace.custom_profit =  self.freelancer_fee
    self.package_workspace.save

    MemberMailerWorker.perform_async(member_id: self.employer.id.to_s, package_order_id: self.id.to_s, perform: :send_package_workspace_created_to_employer)
    MemberMailerWorker.perform_async(member_id: self.freelancer.id.to_s, package_order_id: self.id.to_s, perform: :send_package_workspace_created_to_freelancer)
    TeamMailerWorker.perform_async(package_order_id: self.id.to_s, perform: :send_package_workspace_created)

    routes = Rails.application.routes.url_helpers
    bitly_url = Api::BitlyService.new.short_it(routes.workspace_url(self.freelancer.locale.to_s, self.package_workspace))
    ZenzivaWorker.perform_async(perform: :send_sms, to: self.freelancer.contact_number, text: I18n.t('sms.freelancer.you_got_package_order', :employer_name => self.employer.username, :url => bitly_url))
  end

  # this method is after package order created but not paid yet
  def notify
    MemberMailerWorker.perform_in(15.minutes, member_id: self.employer.id.to_s, package_order_id: self.id.to_s, perform: :send_package_invoice_to_employer)
    #TeamMailerWorker.perform_async(package_order_id: self.id.to_s, perform: :send_new_package_order)
  end

  def has_brief?
    !self.description.blank? or !self.attachments.blank?
  end

  def fee
    # Service fee untuk Sribulancer
    self.budget - self.freelancer_fee
  end

  def fee_display
    "#{self.currency.code} #{number_to_currency(self.fee, unit: '', precision: self.currency.precision_to_use)}"
  end

  def total_cost_display
    temp_payment_code = (self.currency.code == "IDR") ? self.payment_code : 0

    promotion_value = get_promotion_value

    "#{self.currency.code} #{number_to_currency(self.budget - promotion_value + temp_payment_code, unit: '', precision: self.currency.precision_to_use)}"
  end

  def for_testing?
    self.employer.for_testing?
  end

  def payment_code_display
    payment_code = self.currency.code == "IDR" ? self.payment_code : 0
    "#{self.currency.code} #{number_to_currency(payment_code, unit: '', precision: self.currency.precision_to_use)}"
  end

  def get_cc_fee_veritrans(budget)
    promotion_value = get_promotion_value
    (budget - promotion_value) / 100 * VT_SETTING['cc_fee']
  end

  def total_cost_veritrans
    to_currency = Currency.where(code: 'IDR').first

    budget = self.currency.convert_to_currency(to_currency, self.budget).ceil

    promotion_value = get_promotion_value

    cc_fee = get_cc_fee_veritrans(budget)
    total = (budget - promotion_value) + cc_fee
    total
  end

  def workspace
    self.package_workspace
  end

  def buyer_name
    self.employer.name
  end

  # set order budget taken from the package
  def set_budget
    self.budget = self.package.price + self.affiliate_fee
    self.freelancer_fee = self.package.freelancer_fee
  end

  def object
    self.package
  end

  def get_promotion_value
    if self.promotion.present?
      p = Promotion.find(self.promotion)
      if p.voucher_type == 'Nominal'
        promotion_value = p.voucher_value if p.present?
      else
        promotion_value = self.budget - (self.budget * (p.voucher_value/100) )
      end
    end
    return (promotion_value || 0)
  end

end
