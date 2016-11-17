# ================================================================================
# Part: STORE
# Desc:
# Multiple Table Inheritance for StoreItem, Member, Invoice, Workspace
# ================================================================================
class StorePurchase
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ownerable

  #                                                                          Field
  # ==============================================================================
  field :prize
  # Flag if prize was raised to designer
  field :deposit_raised, type: Boolean, default: false

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :owner, polymorphic: true
  belongs_to :item, class_name: "StoreItem"
  belongs_to :status, class_name: "StorePurchaseStatus"
  belongs_to :invoice, class_name: "StoreInvoice"
  has_one :workspace, class_name: "StoreWorkspace"

  # Affiliate
  has_one :affiliate_referred_by, class_name: "AffiliateClaimStore", foreign_key: "store_purchase_id" # Referred affiliate
  has_many :store_unpaid_tickets

  #                                                                     Validation
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
  end

  after_save do
    claim_affiliate
  end


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================
  def is_first_store_purchase?
    self.owner.store_purchases.count == 1
  end

  # Statuses
  def is_draft?
    self.status == StorePurchaseStatus.draft
  end

  def is_not_active?
    self.status == StorePurchaseStatus.not_active
  end

  def is_open?
    self.status == StorePurchaseStatus.open
  end

  def is_closed?
    self.status == StorePurchaseStatus.closed
  end

  def is_refund?
    self.status == StorePurchaseStatus.refund
  end


  def set_default_attributes
    self.prize = self.item.calculate_prize if self.prize.blank?
  end

  # Create affiliate claim if store_purchase is first store_purchase
  def claim_affiliate
    # Claim affiliate
    raise if !self.is_first_store_purchase?
    raise if AffiliateClaimStore.where(store_purchase: self).present?

    # Find owner referred by
    affiliate = self.try(:owner).try(:affiliate_referred_by).try(:affiliate)
    raise if affiliate.blank?

    # Find affiliate publisher
    publisher = affiliate.publisher

    # Hitung commission berdasarkan berapa banyak publisher telah menghasilkan
    # store_purchase yang berhasil di close (bayar)
    aff_success = publisher.affiliate_referring(type: "store", status: "success")
    if aff_success.count < 10
      commission = AffiliateCommissionStore.find_by(quantity: 0)
    elsif aff_success.count >= 10
      commission = AffiliateCommissionStore.find_by(quantity: 10)
    end

    # Create AffiliateClaim record
    # Commission akan diberikan ketika store_purchase statusnya closed
    AffiliateClaimStore.create(affiliate: affiliate, store_purchase: self, commission: commission)

  rescue
    nil
  end

end
