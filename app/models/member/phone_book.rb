# ================================================================================
# Part:
# Desc:
# ================================================================================
class PhoneBook
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_save do
    generate_msisdn
  end

  #                                                                          Field
  # ==============================================================================

  field :title, type: String
  field :contact_number, type: String
  field :default_number, type: Boolean, default: false
  field :msisdn, type: String


  #                                                                       Relation
  # ==============================================================================
  embedded_in :member
  belongs_to :country


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :contact_number


  #                                                                   Class Method
  # ==============================================================================

  # index({ msisdn: -1 }, { sparse: true })
  #                                                                         Method
  # ==============================================================================
  # Updating or generate msisdn from contact_number and country phone_code
  def generate_msisdn
    self.msisdn = self.country.phone_code + self.contact_number unless self.contact_number.blank? or self.country.blank?
  end


end
