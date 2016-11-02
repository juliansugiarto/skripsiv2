# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# Place all transaction receipt here (payment confirm, etc)
# ================================================================================
class PaymentConfirmation
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  field :amount, type: Float
  field :payment_method # credit_card, paypal, bank_transfer
  field :payment_time, type: DateTime
  field :bank_name
  field :bank_account
  field :note
  field :attachment

  # Migration from contest, file available in S3 but cannot accessed by new Uploader
  # because has different model, so i save here in case we can use it later
  field :old_attachment


  mount_uploader :attachment, PaymentConfirmationUploader

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :author, polymorphic: true
  belongs_to :payment

  #                                                                     Validation
  # ==============================================================================
  validates :amount, presence: true

  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================

end
