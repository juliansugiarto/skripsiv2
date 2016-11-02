# ================================================================================
# Part:
# Desc:
# ================================================================================
class UserLevel
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :create_resource, type: Boolean, default: false
  field :read_resource, type: Boolean, default: false
  field :update_resource, type: Boolean, default: false
  field :delete_resource, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :user_resource

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
