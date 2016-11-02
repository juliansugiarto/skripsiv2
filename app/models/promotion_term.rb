# ================================================================================
# Part:
# Desc:
# ================================================================================
class PromotionTerm
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  # Each package could have a different discount
  field :discount_type # percentage, nominal
  field :discount, type: Float, default: 0

  #                                                                       Relation
  # ==============================================================================
  embedded_in :promotion
  belongs_to :package

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
