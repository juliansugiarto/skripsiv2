# ================================================================================
# Part:
# Desc:
# ================================================================================
class BankAccount
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================
  BCA = 'bca'
  BNI = 'bni'
  MANDIRI = 'mandiri'

  VISA = 'visa'
  MASTER = 'master'

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_save :upcase_attributes

  #                                                                          Field
  # ==============================================================================
  field :bank_name, type: String
  field :account_number, type: String
  field :account_name, type: String
  field :branch, type: String

  field :old_bank_id
  field :old_bank_name
  field :old_account_number
  field :old_account_name
  field :old_branch
  field :request_for

  #                                                                       Relation
  # ==============================================================================
  belongs_to :member
  belongs_to :bank
  has_many :withdrawal_deposit

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :bank_id, :account_number, :account_name, :branch


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  private
  def upcase_attributes
    self.try(:account_name).try(:upcase!)
    self.try(:branch).try(:upcase!)
  end
end
