# ================================================================================
# Part:
# Desc:
# ================================================================================
class Payment
  include Mongoid::Document
  include Mongoid::Timestamps
  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :amount, type: Float
  field :verified, type: Boolean, default: false # verified == paid

  #                                                                       Relation
  # ==============================================================================
  belongs_to :invoice
  belongs_to :payment_method
  has_many :transaction_references, as: :reference
  has_many :payment_confirmations

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  # Getter, from invoice
  def currency_exchanges
    self.invoice.currency_exchanges
  end
  
end
