# ================================================================================
# Part:
# Desc:
# ================================================================================
class FileTransfer
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
  field :deadline, type: Time, default: Time.now + 5.days
  field :active, type: Boolean, default: true

  #                                                                       Relation
  # ==============================================================================
  belongs_to :winner
  belongs_to :store_purchase
  belongs_to :workspace

  has_one :ticket, class_name: "FileTransferTicket"

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
