# ================================================================================
# Part:
# Desc:
# ================================================================================
class TicketEvent
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
  field :is_deleted, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :ticket, polymorphic: true
  # Author for this event, such as User
  belongs_to :author, polymorphic: true

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
