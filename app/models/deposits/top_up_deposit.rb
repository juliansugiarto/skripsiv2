# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# STI for Deposit model
# Should have transaction
# ================================================================================
class TopUpDeposit < Deposit

  #                                                                          Field
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :invoice


  #                                                                     Validation
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================
end