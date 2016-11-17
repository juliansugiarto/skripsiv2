# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# Place all transaction code here
# ================================================================================
class TransactionCode
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :cname, type: String
  field :slug, type: String
  field :description, type: String
  field :code, type: String # TransactionCode code
  field :account_entry, type: String # TransactionCode type (DB/CR)


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  has_many :transactions


  #                                                                     Validation
  # ==============================================================================
  validates :code, presence: true, uniqueness: true
  validates :account_entry, presence: true
  validates :name, presence: true


  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================
  class << self

    def payout
      find_by(cname: "payout")
    end

    def client_payment
      find_by(cname: "client_payment")
    end

    def client_refund
      find_by(cname: "client_refund")
    end

    def top_up
      find_by(cname: "top_up")
    end


  end

  #                                                                         Method
  # ==============================================================================

end
