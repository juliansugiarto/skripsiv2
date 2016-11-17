# ================================================================================
# Part:
# Desc:
# ================================================================================
class StoreInvoice < Invoice
  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================

  # TODO:
  # Migrate this into payment
  # STORE INVOICE
  field :payment_date
  field :payment_method
  field :auto_confirmation

  # store payment confirmation
  field :payment_date_manual, type: DateTime
  field :confirm_payment_bank # Bank select
  field :confirm_payment_nominal
  field :confirm_payment_info
  field :payment_attachment

  #mark for workspace has been open after invoice status paid
  field :mark_as_open, type: DateTime

  #                                                                       Relation
  # ==============================================================================
  # In case one invoice can be purchase many item
  has_many :store_purchases

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

end
