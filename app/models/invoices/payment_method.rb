# ================================================================================
# Part:
# Desc:
# ================================================================================
class PaymentMethod
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
  field :name
  field :cname
  field :slug
  field :description
  field :active, :default => false

  #                                                                       Relation
  # ==============================================================================
  has_many :payments

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================
  class << self
    def bank_transfer_bca
      find_by(cname: "bank_transfer_bca")
    end

    def bank_transfer_mandiri
      find_by(cname: "bank_transfer_mandiri")
    end

    def paypal
      find_by(cname: "paypal")
    end

    def credit_card
      # Credit Card by VT Direct
      find_by(cname: "credit_card")
    end

    def vt_web
      # Credit Card by VT Web
      find_by(cname: "vt_web")
    end

    def vt_link
      find_by(cname: "vt_link")
    end

    def other
      find_by(cname: "other")
    end

    def deposit
      find_by(cname: "deposit")
    end

    def vt_web
      find_by(cname: "vt_web")
    end
  end

  #                                                                         Method
  # ==============================================================================

end
