# ================================================================================
# Part:
# Desc:
# ================================================================================
class WorkspaceEvent
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
  field :body, type: String
  field :read, type: Boolean, default: false
  field :temp_id, type: String

  #                                                                       Relation
  # ==============================================================================
  # Author event can be member (CH, Designer), user, system, robot, etc
  belongs_to :author, polymorphic: true
  embedded_in :workspace

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
