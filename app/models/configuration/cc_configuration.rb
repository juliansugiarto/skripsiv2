# ================================================================================
# Part: 
# Desc:
# ================================================================================
class CcConfiguration
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :use_cc_bni_feature_discount, type: Boolean, default: false

  field :use_cc_bni_discount, type: Boolean, default: false
  field :use_cc_bca_discount, type: Boolean, default: false
  field :use_cc_mandiri_discount, type: Boolean, default: false
  field :use_cc_visa_discount, type: Boolean, default: false
  field :use_cc_master_discount, type: Boolean, default: false

  field :cc_bni_discount_value, type: Float, default: 0
  field :cc_bca_discount_value, type: Float, default: 0
  field :cc_mandiri_discount_value, type: Float, default: 0
  field :cc_visa_discount_value, type: Float, default: 0
  field :cc_master_discount_value, type: Float, default: 0

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
