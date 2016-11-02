# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# Deposit history for each use save here
# ================================================================================
class Deposit
  include Mongoid::Document
  include Mongoid::Timestamps
  include CurrencyExchange

  #                                                                          Field
  # ==============================================================================
  field :description # Generate automatic by system
  field :amount, type: Float
  field :balance, type: Float # Must be allow minus value
  # Denormalize form deposit_code table
  field :code # deposit transaction code
  field :account_entry # deposit transaction type (DB/CR)
  # Don't count amount as balance if not verified
  field :verified, type: Boolean, default: true
  # Save meta data here (JSON) if exists
  # Save anything transaction meta data
  field :meta

  # Save all foreign currency exchange in the time when object created,
  # Avoid change value in future
  field :currency_exchanges, type: Array



  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  # Can be user, or vendor
  belongs_to :owner, polymorphic: true
  belongs_to :deposit_code # Type of transaction
  belongs_to :status, class_name: "DepositStatus"

  # WithdrawalDeposit should have transaction
  # Every deposit that associated with real company transaction, should have transaction
  belongs_to :transaction


  #                                                                     Validation
  # ==============================================================================
  validates :deposit_code, presence: true
  validates :owner, presence: true
  validates :account_entry, presence: true
  validates :code, presence: true
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 0}


  #                                                                       Callback
  # ==============================================================================
  before_create do
    normalize_balance
    adjustment_balance
    set_currency_exchanges
  end

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  # Normalize balance whenever object called
  def normalize_balance
    # Adjust previous balace
    previous_balance = 0
    deposits = Deposit.where(owner: self.owner, :id.nin => [self.id]).asc(:created_at)
    deposits.each do |d|
      # Skip counting if record not verified yet
      next if !d.verified or [DepositStatus.deleted, DepositStatus.denied].include? d.status

      # Adjust previous balance
      case d.account_entry
      when "CR" # Means credit (addition)
        previous_balance = previous_balance + d.amount
      when "DB" # Means debit (reduction)
        previous_balance = previous_balance - d.amount
      end
      d.update_attribute(:balance, previous_balance)
    end
    return previous_balance
  end


  protected
  # adjusment balance before save new record
  def adjustment_balance

    # Get current balance from previous transaction
    current_balance = self.normalize_balance.to_f

    # Adjust new balance if verified
    if self.verified or ![DepositStatus.deleted, DepositStatus.denied].include? d.status
      case self.account_entry
      when "CR" # Means credit (addition)
        self.balance = current_balance + self.amount.to_f
      when "DB" # Means debit (reduction)
        self.balance = current_balance - self.amount.to_f
      end

    # Save old balance if not verified
    else
      self.balance = current_balance
    end

  end

end
