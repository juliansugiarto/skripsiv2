# ================================================================================
# Part: BALANCE SYSTEM
# Desc:
# STI for Deposit model
# Should have transaction
# ================================================================================
class WithdrawalDeposit < Deposit

  #                                                                          Field
  # ==============================================================================
  # field :bank_name, type: String
  # field :account_name, type: String
  # field :account_number, type: String
  # field :branch, type: String
  field :actual_payment

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :withdrawal_bank, class_name: "BankAccount"

  #                                                                     Validation
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_save do
    set_actual_payment
  end

  #                                                                   Class Method
  # ==============================================================================
  def set_actual_payment
    if self.amount?
      self.actual_payment = amount - (amount * 3 / 100)
    end
  end

  #                                                                Instance Method
  # ==============================================================================


end
