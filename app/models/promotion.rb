# ================================================================================
# Part:
# Desc:
# ================================================================================
class Promotion
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  # Old fields
  # field :universal_voucher, type: Boolean, default: false
  # field :discount_flat, type: Float, default: 0

  # New fields
  field :name, type: String
  field :description, type: String
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :active, type: Boolean
  field :quota, type: Integer # Discount usages quota
  field :universal, type: Boolean, default: false
  field :discount_type # percentage, nominal
  field :discount, type: Float, default: 0 # Amount discount, percentage or nominal

  #                                                                       Relation
  # ==============================================================================
  belongs_to :author, polymorphic: true # User
  has_many :vouchers
  has_and_belongs_to_many :categories # Valid categories that can use this promotion
  # Different packages has different discount
  embeds_many :terms, class_name: "PromotionTerm"

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
  def is_expired?
    self.end_date < DateTime.now
  end

end
