# ================================================================================
# Part:
# Desc:
# ================================================================================
class YearlySalesTarget
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
  # Monthly Target
  field :year, type: Integer
  field :january, type: Float, default: 0
  field :february, type: Float, default: 0
  field :march, type: Float, default: 0
  field :april, type: Float, default: 0
  field :may, type: Float, default: 0
  field :june, type: Float, default: 0
  field :july, type: Float, default: 0
  field :august, type: Float, default: 0
  field :september, type: Float, default: 0
  field :october, type: Float, default: 0
  field :november, type: Float, default: 0
  field :december, type: Float, default: 0

  #                   ``                                                    Relation
  # ==============================================================================


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
