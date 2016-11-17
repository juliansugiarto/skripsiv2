# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# Multiple Table Inheritance for transaction, such as order, user, agent, receipt
# Belong to transactions table
# ================================================================================
class TransactionReference
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  # Can be invoice, member, user, payment_confirmation, or any object
  belongs_to :reference, polymorphic: true
  belongs_to :transaction


  #                                                                     Validation
  # ==============================================================================
  validates :reference_id, presence: true
  validates :reference_type, presence: true
  validates :transaction, presence: true


  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================
end
