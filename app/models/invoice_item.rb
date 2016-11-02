# ================================================================================
# Part:
# Desc:
# ================================================================================
class InvoiceItem
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  # NEW FIELD STRUCTURE (Universal)
  field :description
  field :quantity, type: Integer, default: 1
  field :discount, type: Float, default: 0
  # harga paket asli (sesudah promo) + additional winners + features. Ini yang harus dibayarkan oleh CH
  field :sub_total, type: Float, default: 0
  field :tax, type: Float, default: 0
  field :total, type: Float, default: 0
  field :amount, type: Float, default: 0 # Same as total
  field :profit, type: Float, default: 0

  # For history
  field :migrated_from

  #                                                                       Relation
  # ==============================================================================
  belongs_to :invoice
  belongs_to :purchasable, polymorphic: true

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
  # Getter, from invoice
  def currency_exchanges
    self.invoice.currency_exchanges
  end

end
