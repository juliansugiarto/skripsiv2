class Order

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  store_in database: 'sribulancer_development', collection: 'orders'
  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  attr_accessor :card_number, :card_expiry, :card_holder_name, :card_cvv, :vt_token

  PAYMENT_TYPE = ["BCA", "MANDIRI", "PAYPAL", "CC"]

  field :invoice_number
  field :payment_code, type: Integer, default: 0
  field :budget, type: Float

  field :payment_done_by
  field :payment_done_on, type: DateTime

  # =====================================
  # DENORMALIZED
  # Be careful with these field.
  # =====================================
  # if job, owner is employer,
  # if service, owner is freelancer
  field :owner_id
  field :owner_username
  field :owner_email
  # if job, requester is freelancer,
  # if service, requester is employer
  field :requester_id # (if ServiceOrder, DONT USE THIS FIELD, please use employer_id instead of this field, because it'll have duplicate value)
  field :requester_username
  field :requester_email
  # for job/service title.
  field :ordered_title
  field :promotion
  # when admin marks order paid
  field :paid_at, type: DateTime
  # =====================================

  # FLAG
  field :fu, type: Boolean, default: false

  validates :owner_email, presence: true

  belongs_to :order_status
  belongs_to :currency

  embeds_one :payment_confirm

  before_create :set_status_initiated

  after_create :handle_testing

  scope :created_at_desc, -> {desc(:created_at)}
  scope :paid_at_desc, -> {desc(:paid_at)}

  scope :paid, -> { where(order_status_id: OrderStatus.get_paid.id) }

  scope :unpaid, -> { where(order_status_id: OrderStatus.get_initiated.id) }
  scope :not_rejected, -> { where(:order_status_id.ne => OrderStatus.rejected.id) }

  def set_status_initiated
    self.order_status = OrderStatus.get_initiated
    self.invoice_number = self.object.class.to_s[0] + "#{DateTime.now.strftime('%Y%m')}#{rand(10000..30000)}"
    self.payment_code = rand(1..999)
  end

  def set_status_paid
    self.order_status = OrderStatus.get_paid
    self.paid_at = Time.now
  end

  def reject
    self.order_status = OrderStatus.rejected
    self.save(validate: false)
  end

  def set_status_cancel
    self.order_status = OrderStatus.get_cancel
    self.save
  end

  def initiated?
    self.order_status == OrderStatus.get_initiated
  end

  def cancel?
    self.order_status == OrderStatus.get_cancel
  end

  def paid?
    self.order_status == OrderStatus.get_paid
  end

  def rejected?
    self.order_status == OrderStatus.rejected
  end

  def status_display
    if self.initiated?
      status = 'warning'
      name = 'Unapproved'
    elsif self.cancel?
      status = 'danger'
      name = 'Cancel'
    elsif self.paid?
      status = 'success'
      name = 'Paid'
    elsif self.rejected?
      status = 'warning'
      name = 'Rejected'
    end

    return (status.present? ? "<span class='label label-#{status}'>#{name.titleize}</span>".html_safe : "Orphan")
  end

  def vt_direct
    puts "wwwwww"
  end

  def self.months_of_years
    months = %w{Jan Feb Mar Apr Mei Jun Jul Agu Sep Okt Nov Des}
    i = 0
    months.map do |month|
      i += 1
      zero_lead = "%02d" % i
      ["#{zero_lead} - #{month}","#{zero_lead}"]
    end
  end

  def self.valid_years
    base = Time.now.year
    coll = []
    10.times do |i|
      current = base
      base +=1
      coll << ["#{current}", "#{current}"]
    end
    coll
  end

  # auto marks as paid if user is testing
  def handle_testing
    if self.for_testing?
      self.mark_as_paid
    end
  end

  def budget_display
    "#{self.currency.code} #{number_to_currency(self.budget, unit: '', precision: self.currency.precision_to_use)}"
  end

  def object
    if self.is_a? JobOrder
      self.job
    elsif self.is_a? TaskOrder
      self.task
    elsif self.is_a? ServiceOrder
      self.service
    end
  end

end
