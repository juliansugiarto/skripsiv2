# ================================================================================
# Part:
# Desc:
# ================================================================================
class InvoiceItemUpgrade < InvoiceItem

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================
  # attr_accessor :old_package, :new_package

  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
    calculate_total
  end

  #                                                                          Field
  # ==============================================================================
  # UPGRADE CONTEST
  field :upgrade_price, type: Float, default: 0
  field :transaction_fee, type: Float, default: 0
  field :free_upgrade, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :contest_upgrade

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
    self.quantity = 1

    case self.purchasable.class
    when Package
      self.description = "Upgrade package to #{self.purchasable.name}"
      # Hitung kekurangan dari paket sebelumnya
      old_package = self.invoice.contest_upgrade.old_package
      new_package = self.invoice.contest_upgrade.new_package
      price = new_package.calculate_sell_price - old_package.calculate_sell_price
      self.upgrade_price = price
      self.transaction_fee = 300000
    when Feature
      self.description = "Upgrade feature to #{self.purchasable.name}"
      if !self.free_upgrade
        self.upgrade_price = self.purchasable.price
      else
        self.upgrade_price = 0
      end
    end

  end

  def calculate_total
    # Calculate total
    self.sub_total = self.upgrade_price + self.transaction_fee
    self.tax = self.sub_total * (Percentage::TAX_FEE/100)
    self.total = self.sub_total + self.tax
    self.amount = self.total
    self.profit = self.transaction_fee
  end

end
