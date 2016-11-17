# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# Record all transaction than have relation with company transaction
# income, and outcome
# Payment from client to us, refund, etc
# ================================================================================
class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps
  include CurrencyExchange

  #                                                                       Constant
  # ==============================================================================
  TRANSACTION_TRANSFER_TYPE = 'transfer'
  TRANSACTION_PAYPAL_TYPE   = 'paypal'
  TRANSACTION_CC_TYPE       = 'cc'
  TRANSACTION_TOPUP_TYPE    = 'topup'

  TRANSACTION_PENDING_STATUS  = 'pending'
  TRANSACTION_PAID_STATUS     = 'paid'

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_validation do
    set_default_attributes
    set_currency_exchanges
  end

  #                                                                          Field
  # ==============================================================================
  field :description, type: String # Generate automatic by system
  field :amount, type: Float
  field :note, type: String

  # Denormalize form transaction_codes table
  field :code, type: String # TransactionCode code
  field :account_entry, type: String # TransactionCode type (DB/CR)

  # Don't count amount as balance if not verified
  field :verified, type: Boolean, default: false

  # Save all foreign currency exchange in the time when object created,
  # Avoid change value in future
  field :currency_exchanges, type: Array

  # OLD FIELD
  # Should be deleted after migration
  field :trx_id,        type: String
  field :trx_amount,    type: Float
  field :trx_contest,   type: String
  field :trx_type,      type: String, default: 'transfer'
  field :trx_status,    type: String, default: 'pending'
  field :trx_owner,     type: String
  field :trx_discount_cc, type: Float, default: 0
  field :trx_detail,    type: String
  field :trx_currency,  type: String, default: "IDR"
  field :approved_date, type: DateTime
  # Only for veritrans payment
  field :vt_order_id
  field :vt_transaction_id
  # From Payment
  field :info, type: String
  field :date_processed, type: DateTime
  field :designer_name, type: String
  field :before_tax, type: Float
  field :after_tax, type: Float
  field :tax, type: Float
  field :payout_other_bca_fee, type: Float, default: 0
  field :bank_name, type: String
  field :account_name, type: String
  field :account_number, type: String
  field :branch, type: String

  #                                                                       Relation
  # ==============================================================================
  belongs_to :transaction_code # Type of transaction
  has_one :deposit # every deposit should have transaction record
  has_many :transaction_references # User, member, contest, invoice, or any object

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates :transaction_code, presence: true
  validates :account_entry, presence: true
  validates :code, presence: true
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: -1}


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def update_veritrans_payment
    self.trx_type = Transaction::TRANSACTION_CC_TYPE
    self.trx_status = Transaction::TRANSACTION_PAID_STATUS
    self.save
  end

  def set_default_attributes
    self.code = self.transaction_code.code
    self.account_entry = self.transaction_code.account_entry
  end


end
