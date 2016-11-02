# ================================================================================
# Part:
# Desc:
# ================================================================================
class InvoiceItemContest < InvoiceItem

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
    apply_promotion
    calculate_total
  end

  before_save do
    apply_promotion
    calculate_total
  end

  #                                                                          Field
  # ==============================================================================
  # CONTESTS
  # Package prize
  field :package_prize, type: Float, default: 0 # Change by discount
  # Features price
  field :private_price, type: Float, default: 0
  field :confidential_price, type: Float, default: 0
  field :fast_tracked_price, type: Float, default: 0
  field :extend_price, type: Float, default: 0
  field :guarantee_price, type: Float, default: 0
  # Fee price
  field :posting_fee, type: Float, default: 0
  field :transaction_fee, type: Float, default: 0 # Change by discount

  # TODO:
  # DEPRECATED, DELETED SOON
  # Discount and promotion
  field :discount_cc, type: Float, default: 0
  field :discount_flat, type: Float, default: 0
  # harga paket asli (sebelom promo) + additional winners + features
  field :total_ori, type: Float, default: 0
  # harga paket asli setelah dipotong credit card discount
  field :total_ori_cc, type: Float, default: 0
  # synchronize with total amount of upgrade features prices contest have.
  field :total_upgrade_features_prices, type: Float, default: 0
  # Field from extend invoice
  field :runnerup_winner, type: String, default: "runner-up"
  field :extended_invoice_type # How the invoice triggered apear
  field :client_has_paid, type: Boolean, default: false
  field :upgrade_fee, type: Float, default: 0 # Same as amount
  field :from_soft_selling, type: Boolean, default: false
  field :temporary_feature_id
  field :upgrade_package_to_type
  field :upgrade_package_to_id
  field :flat, type: Boolean, default: false # Flag promotion
  field :promotion_name
  field :credit_card, type: String
  field :need_help, type: Float, default: 0

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
  def set_default_attributes
    self.description = "Buy a contest" if self.description.blank?
    self.quantity = 1 if self.quantity.blank? or self.quantity.zero?
  end

  # Huge calculation logic
  def apply_promotion
    redemption = Redemption.find_by(
      claimer: self.invoice.owner,
      invoice: self.invoice
    )
    voucher = redemption.coupon
    raise if voucher.blank? or !voucher.active?
    promotion = voucher.promotion
    raise if promotion.blank?
    raise if promotion.is_expired?

    # Check voucher already redeem or not
    # If promotion not universal
    unless promotion.universal
      raise if Redemption.find_by(coupon: voucher).present?
    end

    # If purchasable is contest
    contest = self.purchasable
    winner = contest.get_first_winner
    raise if contest.blank? or winner.blank?

    # Revert back value transaction_fee, transaction_fee, and discount
    self.transaction_fee = contest.calculate_transaction_fee
    self.package_prize = contest.calculate_package_prize

    # Check if purchasable eligible to use this promotion
    # Check by category and package of purchasable (contest)
    raise if !promotion.category_ids.include? contest.category_id
    raise if !promotion.try(:terms).map(&:package_id).include? contest.package_id

    term = promotion.terms.find_by(package_id: contest.package_id)

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

    case dsc_type
    when "percentage"
      d_pp = self.package_prize * (0.8 * (dsc / 100))
      d_tf = self.transaction_fee * (0.2 * (dsc / 100))
      self.package_prize = self.package_prize - d_pp
      self.transaction_fee = self.transaction_fee - d_tf
      winner.update_attribute(:prize, self.package_prize)
    when "nominal"
      d_pp = 0.8 * dsc
      d_tf = 0.2 * dsc
      self.package_prize = self.package_prize - d_pp
      self.transaction_fee = self.transaction_fee - d_tf
      winner.update_attribute(:prize, self.package_prize)
    end

    # Save discount as total_nominal
    self.discount = d_pp.to_f + d_tf.to_f
  rescue
    contest = self.purchasable
    winner = contest.get_first_winner
    # Revert back value transaction_fee, transaction_fee, and discount
    self.transaction_fee = contest.calculate_transaction_fee
    self.package_prize = contest.calculate_package_prize
    self.discount = 0
    winner.update_attribute(:prize, self.package_prize)
  end

  def total_feature_price
    t = 0
    Feature.where(active: true).each do |f|
      t = t + self.send("#{f.cname}_price")
    end
    return t
  end

  def calculate_total
    # Calculate total
    self.sub_total = self.package_prize + self.transaction_fee + self.posting_fee + total_feature_price
    self.tax = self.sub_total * (Percentage::TAX_FEE/100)
    self.total = self.sub_total + self.tax
    self.amount = self.total
    self.profit = self.sub_total - self.package_prize
  end

  def reset_feature_price
    # Set to zero all feature price
    Feature.where(active: true).each do |f|
      self.send "#{f.cname}_price=", 0
    end
  end

end
