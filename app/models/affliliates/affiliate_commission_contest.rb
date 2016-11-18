# ================================================================================
# Part:
# Desc:
# ================================================================================
class AffiliateCommissionContest < AffiliateCommission

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :quantity # Greater than this
  field :saver_commission, type: Float
  field :bronze_commission, type: Float
  field :silver_commission, type: Float
  field :gold_commission, type: Float

  #                                                                       Relation
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