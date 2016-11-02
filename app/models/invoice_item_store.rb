# ================================================================================
# Part:
# Desc:
# ================================================================================
class InvoiceItemStore < InvoiceItem

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
  # FROM STORE
  # field :price_total :total # Yang harus dibayar oleh client (termasuk kalo sudah ada tax, discount dll)
  field :price_original # Harga sebelum tax, discount dll
  # field :tax
  field :status
  field :license # Yang didapat oleh desainer
  field :revision # Yang didapat oleh desainer
  field :payment_request_date, type: DateTime
  # true berarti ordered_item ini mendapatkan diskon.
  # Karena 1 invoice bisa punya banyak ordered_item dan tidak semua ordered_item tersebut dapat diskon.
  field :discounted, :type => Boolean, :default => false
  # Ini dipakai kalau ada discount langsung dari admin, tidak bisa digabungkan
  # dengan voucher discount biasa dan buyer tidak perlu masukkan voucher code.
  # Valuenya misal IDR 90.000 untuk potongan sebesar 90.000, TIDAK simpan persentase. Persentase harus diconvert ke bentuk nominal.
  field :admin_discount_value, type: Float, default: 0
  field :bank_account_id # Bank account, useless

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
    self.description = "Buy a store item" if self.description.blank?
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
      d_po = self.price_original * (0.8 * (dsc / 100))
      self.price_original = self.price_original - d_po
      self.discounted = true
    when "nominal"
      d_po = 0.8 * dsc
      self.price_original = self.price_original - d_po
      self.discounted = true
    end

    # Save discount as total_nominal
    self.discount = d_po.to_f
  rescue
    self.price_original = self.purchasable.calculate_sell_price
    self.discount = 0
  end

  # All calculation goes here
  def calculate_total
    # Calculate total
    self.sub_total = self.price_original
    self.tax = self.sub_total * (Percentage::TAX_FEE/100)
    self.total = self.sub_total + self.tax
    self.amount = self.total
    self.profit = self.sub_total
  end

end
