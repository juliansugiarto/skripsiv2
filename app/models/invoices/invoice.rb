# ================================================================================
# Part:
# Desc:
# Invoice
# ├── InvoiceItems
# │   ├── Contest
# │   │   ├── description
# │   │   ├── quantity
# │   │   ├── discount
# │   │   ├── tax
# │   │   └── amount
# │   ├── Task
# │   ├── Design
# │   └── etc.
# ├── sub_total
# └── total
# ================================================================================
class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps
  include CurrencyExchange
  include Ownerable

  #                                                                       Constant
  # ==============================================================================
  INVOICE_CREDIT_CARD_PROMOTION = %w(visa)
  INVOICE_VISA = INVOICE_CREDIT_CARD_PROMOTION[0]

  PROMOTION_VISA_PERCENTAGE = 0.15
  PROMOTION_VISA_LABEL = 'Visa Promo'

  #                                                                  Attr Accessor
  # ==============================================================================
  attr_accessor :is_changed # Flag that invoice has been changed

  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_status
    generate_invoice_number
    generate_unique_code
    set_currency_exchanges
  end

  #                                                                          Field
  # ==============================================================================
  field :number # Invoice number
  field :unique_code, type: Integer, default: 0

  # flag, apakah sudah pernah kirim email ke CH & Copy order ke Admin
  field :email_sent, type: Boolean, default: false

  # Save all foreign currency exchange in the time when object created,
  # Avoid change value in future
  field :currency_exchanges, type: Array

  #will be filled when invoice paid
  field :paid_at, type: DateTime

  # Google Adwords Stuffs
  field :google_adwords_invoice, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  # Main relationships
  belongs_to :owner, polymorphic: true
  belongs_to :status, class_name: "InvoiceStatus"
  belongs_to :parent, class_name: "Invoice"

  has_many :items, class_name: "InvoiceItem", dependent: :destroy
  has_many :transaction_references, as: :reference
  has_many :payments

  # Promotion/voucher redemption
  has_one :redemption

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================
  def promotion
    self.try(:redemption).try(:promotion)
  end

  def voucher
    self.try(:redemption).try(:coupon)
  end

  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================
  class << self
    def pocode_from_orderid(orderid)
      i = orderid.scan(/\w.{13}/).first
      i =~ /(\w{3})(\w{3})(\w{4})(\w{4})/
      return [$1, $2, $3, $4].join('-')
    end

    def find_by_number(code)
      return nil if code.blank? # validation if code blank

      invoice = Invoice.where(number: code.upcase).first
      if invoice.present?
        invoice
      else
        raise Mongoid::Errors::DocumentNotFound.new(self, "Invoice with #{code} not found")
      end
    end

    def create_for_contest(arg)
      invoice = Invoice.create(
        owner: arg[:owner],
        type: "InvoiceContest",
        contest: arg[:contest]
      )
    end
  end

  #                                                                         Method
  # ==============================================================================
  def is_paid?
    self.status == InvoiceStatus.paid
  end

  def is_unpaid?
    self.status == InvoiceStatus.unpaid
  end

  def is_payment_confirmation_present?
    PaymentConfirmation.where(:payment_id.in => self.payments.map(&:id))
  end

  def calculate_total
    return self.items.sum(:total) + self.unique_code
  end

  def calculate_discount
    return self.items.sum(:discount)
  end

  def calculate_total_no_unique_code
    return self.items.sum(:total)
  end

  # If invoice already paid by another payment method, calculate remains cost
  def calculate_remains
    # Find all verified payments
    paid = Payment.where(invoice: self, verified: true).sum(:amount)
    total = self.calculate_total
    remains = total - paid
  end

  def for_vt
    total = calculate_remains - unique_code
    total = total + (total * 0.04)
    return total
  end

  def cc_fee_only
    total = calculate_remains - unique_code
    total = total * 0.04
    return total
  end

  def to_usd
    total = calculate_remains - unique_code
    self.currency_exchanges.each do |currency|
      total = total * currency[:value] if currency[:code] == "usd"
    end
    return total
  end

  private
  def set_status
    self.status = InvoiceStatus.unpaid if self.status.blank?
  end

  def generate_unique_code
    self.unique_code = (0..9).to_a.shuffle.join.slice(0,3).to_i if self.unique_code.zero?
  end

  def generate_invoice_number
    return if self.number.present?
    invoices = Invoice.where(:created_at.gte => Time.now.beginning_of_month, :created_at.lte => Time.now.end_of_month).asc(:created_at)

    year = self.created_at.strftime('%y')
    month = self.created_at.strftime('%m')
    random_char = ('A'..'Z').to_a.shuffle.join[0..2]
    if invoices.present?
      last_invoice = invoices.last
      if last_invoice.number.present?
        temp_invoice_number = last_invoice.number
        inc = temp_invoice_number.split("-")[3].to_i + 1
        inc = "000000#{inc}"[-4,4]
        self.number = "INV-#{random_char}-#{year}#{month}-#{inc}"
      else
        self.number = "INV-#{random_char}-#{year}#{month}-0001"
      end
    else
      self.number = "INV-#{random_char}-#{year}#{month}-0001"
    end
  end
end
