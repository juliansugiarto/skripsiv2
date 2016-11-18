class TaskOrder < Order
  extend Unscoped

  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  field :budget, type: Float, default: 0

  belongs_to :task
  belongs_to :task_application
  belongs_to :currency

  has_one :task_workspace

  validates :task, presence: true
  validates :task_application, presence: true
  validates :budget, presence: true

  after_create :notify

  unscope :task

  def mark_as_paid
    self.set_status_paid
    self.task_workspace = TaskWorkspace.new(employer_username: self.owner_username, service_provider_username: self.requester_username, zn_payment_code: self.payment_code)
    self.save
    self.notify_all
  end

  # this method is after tasl order created but not paid yet
  def notify
    # MemberMailerWorker.perform_async(member_id: self.employer.id.to_s, job_order_id: self.id.to_s, perform: :send_invoice_to_employer)
    # TeamMailerWorker.perform_async(job_order_id: self.id.to_s, perform: :send_new_job_order)
  end

  # this method is called after task order has been paid
  def notify_all
    MemberMailerWorker.perform_async(member_id: self.service_provider.id.to_s, task_order_id: self.id.to_s, perform: :send_task_paid_to_service_provider)
    MemberMailerWorker.perform_async(member_id: self.employer.id.to_s, task_order_id: self.id.to_s, perform: :send_task_paid_to_employer)
    TeamMailerWorker.perform_async(task_order_id: self.id.to_s, perform: :send_task_order_paid)

    MemberMailerWorker.perform_in(4.hours, member_id: self.employer.id.to_s, task_order_id: self.id.to_s, perform: :resend_task_paid_to_employer)
    MemberMailerWorker.perform_in(4.hours, member_id: self.service_provider.id.to_s, task_order_id: self.id.to_s, perform: :resend_task_paid_to_service_provider)

    km_properties = self.task.km_properties
    km_properties[:paid_task] = self.currency.convert_to_idr(self.budget)
    km_properties[:task_order_id] = self.id.to_s
    km_properties[:type] = self.class.to_s

    KissmetricsWorker.perform_async(perform: :task_paid, identity: self.task.member.email, properties: km_properties)

    # notify other applicants that a freelancer has been hired, only for the first job order
    if self.first_paid_order?
      all_applicants = self.task.task_applications
      all_applicants.each do |ja|
        if ja != self.task_application
          # MemberMailerWorker.perform_async(member_id: ja.member.id.to_s, task_order_id: self.id.to_s, perform: :send_freelancer_hired_to_other_applicants)
        end
      end
    end
  end

  def employer
    self.task.member
  end

  def service_provider
    self.task_application.member
  end

  def service_provider_fee
    self.budget * ((100-StaticDataLancer::TASK_ORDER_PERCENTAGE_FEE).to_f/100.to_f)
  end

  def fee
    # Service fee untuk Sribulancer
    (self.budget * 1.0) * ((StaticDataLancer::TASK_ORDER_PERCENTAGE_FEE * 1.0)/100)
  end

  def fee_display
    "#{self.currency.code} #{number_to_currency(self.fee, unit: '', precision: self.currency.precision_to_use)}"
  end

  def total_cost_display
    temp_payment_code = (self.currency.code == "IDR") ? self.payment_code : 0

    promotion_value = get_promotion_value

    "#{self.currency.code} #{number_to_currency(self.budget - promotion_value + temp_payment_code, unit: '', precision: self.currency.precision_to_use)}"
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
    self.task_workspace
  end

  # check if this is the first paid order for the job
  def first_paid_order?
    paid_orders = self.task.orders.paid

    if paid_orders.blank?
      false
    else
      if paid_orders.first == self
        true
      else
        false
      end
    end
  end

  def for_testing?
    self.task.member.for_testing?
  end

  # set order budget taken from the job applicant budget (bidding)
  def set_budget
    return if self.task_application.blank?
    c = Chat.find_by(task: self.task, service_provider_id: self.requester_id)
    if c.present? and c.events.count > 0
      self.budget = (c.last_bid_value.present?) ? c.last_bid_value : self.task.budget
      self.currency = (c.currency.present?) ? c.currency : self.task.currency
    else
      self.budget = self.task_application.budget
      self.currency = self.task_application.currency
    end
  end

  def budget_payout
    self.budget * ((100-StaticDataLancer::TASK_ORDER_PERCENTAGE_FEE).to_f/100.to_f)
  end

  def budget_payout_display
    "#{self.currency.code} #{number_to_currency(self.budget_payout, unit: '', precision: self.currency.precision_to_use)}"
  end

  def payout_after_tax
    self.budget_payout * ((100-StaticDataLancer::PPH_FEE).to_f/100.to_f)
  end

  def payout_after_tax_display
    "#{self.currency.code} #{number_to_currency(self.payout_after_tax, unit: '', precision: self.currency.precision_to_use)}"
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
