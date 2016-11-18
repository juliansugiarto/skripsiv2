# represent a service posted by employer member
class ServiceOrder < Order
  extend Unscoped
  belongs_to :service
  belongs_to :employer, :class_name => "Member", :foreign_key => 'employer_id'

  has_one :service_workspace

  validates :service, presence: true

  after_create :notify

  unscope :service

  def mark_as_paid
    self.set_status_paid
    self.service_workspace = ServiceWorkspace.new(employer_username: self.requester_username, freelancer_username: self.owner_username, zn_payment_code: self.payment_code)
    self.save
    self.notify_all
  end

  # this method is after service order created but not paid yet
  def notify
    MemberMailerWorker.perform_async(member_id: self.employer.id.to_s, service_order_id: self.id.to_s, perform: :send_service_invoice_to_employer)
    TeamMailerWorker.perform_async(service_order_id: self.id.to_s, perform: :send_new_service_order)
  end

  # this method is called after service order has been paid
  def notify_all
    MemberMailerWorker.perform_async(member_id: self.freelancer.id.to_s, service_order_id: self.id.to_s, perform: :send_service_paid_to_freelancer)
    MemberMailerWorker.perform_async(member_id: self.employer.id.to_s, service_order_id: self.id.to_s, perform: :send_service_paid_to_employer)
    TeamMailerWorker.perform_async(service_order_id: self.id.to_s, perform: :send_service_order_paid)

    km_properties = self.service.km_properties
    km_properties[:paid_service] = self.service.budget_in_currency_without_code(Currency.get_idr.code)
    km_properties[:service_order_id] = self.id.to_s
    km_properties[:type] = self.class.to_s

    KissmetricsWorker.perform_async(perform: :service_paid, identity: self.employer.email, properties: km_properties)
  end

  def freelancer
    self.service.member
  end

  def freelancer_fee
    self.budget * ((100-StaticDataLancer::SERVICE_ORDER_PERCENTAGE_FEE).to_f/100.to_f)
  end

  def fee
    (self.budget * 1.0) * ((StaticDataLancer::SERVICE_ORDER_PERCENTAGE_FEE * 1.0)/100)
  end

  def fee_display
    "#{self.currency.code} #{number_to_currency(self.fee, unit: '', precision: self.currency.precision_to_use)}"
  end

  def total_cost_display
    if self.promotion.present?
      p = Promotion.find(self.promotion)
      if p.voucher_type == 'Nominal'
        self.budget = self.budget - p.voucher_value if p.present?
      else
        self.budget = self.budget - (self.budget * (p.voucher_value/100) )
      end
    end
    temp_payment_code = (self.currency.code == "IDR") ? self.payment_code : 0
    "#{self.currency.code} #{number_to_currency(self.budget + temp_payment_code, unit: '', precision: self.currency.precision_to_use)}"
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

  # set order budget taken from the job applicant budget (bidding)
  def set_budget

    c = Chat.find_by(service: self.service, employer_id: self.requester_id)
    if c.present? and c.events.count > 0
      self.budget = (c.last_bid_value.present?) ? c.last_bid_value : self.service.budget
      self.currency = (c.currency.present?) ? c.currency : self.service.currency
    else
      self.budget = self.service.budget
      self.currency = self.service.currency
    end

  end

  def workspace
    self.service_workspace
  end

  def for_testing?
    self.employer.for_testing?
  end

  def budget_payout
    self.budget * ((100-StaticDataLancer::SERVICE_ORDER_PERCENTAGE_FEE).to_f/100.to_f)
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
