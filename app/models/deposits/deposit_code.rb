# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# Place all transaction code here
# ================================================================================
class DepositCode
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :cname, type: String
  field :slug, type: String
  field :description, type: String
  field :code # TransactionCode code
  field :account_entry # TransactionCode type (DB/CR)


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  has_many :deposits


  #                                                                     Validation
  # ==============================================================================
  validates :code, presence: true, uniqueness: true
  validates :account_entry, presence: true
  validates :name, presence: true

  #                                                                   Class Method
  # ==============================================================================
  class << self
    def withdrawal
      find_by(cname: "withdrawal")
    end

    def cancel_order
      find_by(cname: "cancel_order")
    end

    def commission
      find_by(cname: "commission")
    end

    def prize
      find_by(cname: "prize")
    end

    def no_winner_prize
      find_by(cname: "no_winner_prize")
    end

    def payment
      find_by(cname: "payment")
    end

    def top_up
      find_by(cname: "top_up")
    end

  end

end
