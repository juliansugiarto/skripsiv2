# represent employment history for freelancer
class BankTransferPayout < PayoutMethod

  belongs_to :bank, :foreign_key => :bank_id, inverse_of: nil

  validates :bank_name, presence: true
  validates :account_number, presence: true
  validates :account_name, presence: true
  validates :branch, presence: true

end
