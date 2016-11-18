class PaymentConfirm

  include Mongoid::Document
  include Mongoid::Timestamps

  field :payment_date, type: Date
  field :payment_method
  field :pay_to
  field :amount_paid
  field :bank_account_number
  field :bank_account_name
  field :bank_name
  field :bank_branch
  field :payment_attc
  field :payment_note

  embedded_in :order

  # validates :payment_date, presence: true
  # validates :payment_method, presence: true
  # validates :amount_paid, presence: true
  # validates :bank_account_number, presence: true
  # validates :bank_account_name, presence: true
  # validates :bank_branch, presence: true
  # validates :payment_attc, presence: true

  mount_uploader :payment_attc, PaymentConfirmAttachmentUploader, :only => :create

end
