# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# STI for Deposit model
# ================================================================================
class StorePrizeDeposit < Deposit

  #                                                                          Field
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :store_purchase
  belongs_to :store_item

  #                                                                     Validation
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================
end
