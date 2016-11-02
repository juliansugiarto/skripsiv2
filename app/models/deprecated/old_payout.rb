# Old payout data from old sribu
# Used for migration only (Deposit migration)
# DO NOT use for system
class OldPayout
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  # From Payment and StorePayout Model
  field :type
  field :info
  field :date_processed, type: DateTime
  field :designer_name
  field :designer_username
  field :before_tax, type: Float
  field :after_tax, type: Float
  field :tax, type: Float
  field :payout_other_bca_fee, type: Float, :default => 0

  # field buat simpen pembayaran di bank
  # misal kalau member hapus/edit bank account
  # jadi data pembayaran ke bank sudah di simpan
  field :bank_name
  field :account_name
  field :account_number
  field :branch

  #                                                                       Relation
  # ==============================================================================
  belongs_to :member
  belongs_to :invoice
  belongs_to :invoice_item
  belongs_to :store_item
  belongs_to :entry
  belongs_to :user

end
