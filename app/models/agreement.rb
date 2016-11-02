# ================================================================================
# Part:
# Desc:
# ================================================================================
class Agreement
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ownerable

  #                                                                       Constant
  # ==============================================================================
  AGREEMENT_CODE = 'AGR'


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :designer_approved, type: Boolean, default: false
  field :designer_approved_date, type: DateTime
  field :designer_content_detail
  field :client_approved, type: Boolean, default: false
  field :client_approved_date, type: DateTime
  field :client_content_detail

  # agreement fields
  field :info_contract_no
  field :info_created_date

  field :info_designer_name
  field :info_designer_address
  field :info_designer_notelp
  field :info_designer_nofax
  field :info_designer_email

  field :info_client_company_name
  field :info_client_address
  field :info_client_business_type
  field :info_client_holder
  field :info_client_idcard
  field :info_client_notelp
  field :info_client_nofax
  field :info_client_email


  #                                                                       Relation
  # ==============================================================================
  belongs_to :agreeable, polymorphic: true
  belongs_to :client, class_name: "Member", polymorphic: true
  belongs_to :designer, class_name: "Member", polymorphic: true
  belongs_to :contest


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================
  def self.agreement_code_format(invoice)
    return nil if invoice.number.blank?
    return invoice.number.gsub(/INV-/i, "#{AGREEMENT_CODE}-")
  end

  #                                                                         Method
  # ==============================================================================
  # Override ownerable method
  def is_owned_by?(member = nil)
    return false if member.blank?
    if self.designer == member or self.client == member
      true
    else
      member.is_super_user? ? true : false
    end
  rescue
    false
  end

end
