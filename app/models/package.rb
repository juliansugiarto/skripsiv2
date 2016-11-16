# ================================================================================
# Part:
# Desc:
# ================================================================================
class Package
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================
  BUDGET_DURATION = 3
  BUDGET_SHOW_LIMIT = 15
  BUDGET_UPGRADE_FEE = 300000

  #                                                                  Attr Accessor
  # ==============================================================================
  attr_accessor :benefits, :quality

  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :cname, type: String
  field :slug, type: String
  field :description, type: String
  field :prize, type: Float, default: 0
  field :runner_up_prize, type: Float, default: 0
  field :slot, type: Integer, default: 3
  field :active, type: Boolean, default: true

  # Additional fields
  field :best_package, type: Boolean, default: false
  field :most_popular_package, type: Boolean, default: false



  #                                                                       Relation
  # ==============================================================================
  belongs_to :category
  has_many :contests

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :name
  validates_presence_of :prize
  validates_numericality_of :prize

  #                                                                   Class Method
  # ==============================================================================
  class << self
    def active
      where(active: true)
    end

    def saver(category_id)
      where(name: "Saver", category_id: category_id).first
    end

    def bronze(category_id)
      where(name: "Bronze", category_id: category_id).first
    end

    def silver(category_id)
      where(name: "Silver", category_id: category_id).first
    end

    def gold(category_id)
      where(name: "Gold", category_id: category_id).first
    end
  end

  #                                                                         Method
  # ==============================================================================
  def is_saver?
    cname == "saver"
  end

  def is_bronze?
    cname == "bronze"
  end

  def is_silver?
    cname == "silver"
  end

  def is_gold?
    cname == "gold"
  end

  def is_platinum?
    cname == "platinum"
  end


  def calculate_sell_price
    transaction_fee = self.prize * 0.25
    posting_fee = self.is_saver? ? 0 : Percentage::POSTING_FEE
    price = (self.prize + transaction_fee + posting_fee).to_f
    return price
  end

  def calculate_discount_price(voucher = nil)
    raise if voucher.blank? or !voucher.active?
    promotion = voucher.promotion
    raise if promotion.blank?

    # Check if this package can use the promotion
    raise if !promotion.category_ids.include? self.category_id
    raise if !promotion.try(:terms).map(&:package_id).include? self.id

    term = promotion.terms.find_by(package_id: self.id)

    # If discount set in package term
    if term.discount_type.present? and term.discount > 0
      dsc_type = term.discount_type
      dsc = term.discount
    # If discount set in voucher
    elsif voucher.discount_type.present? and voucher.discount > 0
      dsc_type = voucher.discount_type
      dsc = voucher.discount
    # Set default discount from promotion
    else
      dsc_type = promotion.discount_type
      dsc = promotion.discount
    end

    transaction_fee = self.prize * 0.25

    case dsc_type
    when "percentage"
      d_pp = self.prize * (0.8 * (dsc / 100))
      d_tf = transaction_fee * (0.2 * (dsc / 100))
      discount = d_pp.to_f + d_tf.to_f
    when "nominal"
      d_pp = 0.8 * dsc
      d_tf = 0.2 * dsc
      discount = d_pp.to_f + d_tf.to_f
    else
      raise
    end

    return discount
  rescue
    return 0
  end


  # ==============================================================================
  # PLACE ALL DELETED, MIGRATED, RENAMED OBJECT HERE
  # ==============================================================================

end
