# ================================================================================
# Part:
# Desc:
# ================================================================================
class Voucher
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :code, type: String

  # For manually generate voucher code
  # Old code
  # field :flat, type: Boolean, default: false
  # field :discount, type: Float, default: 0
  # field :discount_flat, type: Float, default: 0

  # New field
  field :included_posting_fee, type: Boolean, default: false
  field :included_tax, type: Boolean, default: false
  field :active, type: Boolean, default: true
  field :discount_type # percentage, nominal
  field :discount, type: Float, default: 0 # Amount discount, percentage or nominal

  #                                                                       Relation
  # ==============================================================================
  belongs_to :promotion
  has_many :redemption, as: :coupon

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
