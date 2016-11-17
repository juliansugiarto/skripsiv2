# ================================================================================
# Part:
# Desc:
# ================================================================================
class Redemption
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :claimer, polymorphic: true # Member
  belongs_to :coupon, polymorphic: true # Can be voucher or referral code
  belongs_to :reference, polymorphic: true # Any object, such as contest, invoice, etc
  belongs_to :invoice
  belongs_to :promotion # Flag only

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
