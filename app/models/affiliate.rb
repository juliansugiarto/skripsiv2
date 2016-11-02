# ================================================================================
# Part:
# Desc:
# ================================================================================
class Affiliate
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
  end

  #                                                                          Field
  # ==============================================================================
  field :code
  field :click_count, type: Integer, default: 0

  # From old table
  field :active, type: Boolean, default: true
  field :message, type: String
  field :affiliate_code, type: String, default: ''
  field :social_media, type: Boolean, default: true
  field :approve_social_media, type: Boolean, default: true
  field :site_url, type: String
  field :site, type: Boolean, default: false
  field :approve_site_url, type: Boolean, default: false
  field :approved_date, :type => DateTime


  #                                                                       Relation
  # ==============================================================================
  belongs_to :promotion
  belongs_to :publisher, polymorphic: true
  has_many :claims, class_name: "AffiliateClaim"

  # Model not exists yet
  # belongs_to :affiliate_level_group

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :publisher
  validates_uniqueness_of :code

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  private
  def set_default_attributes
    # Generate code
    arr = [*'0'..'9', *'A'..'Z']
    arr.reject! {|a| a =~ /O|0|1|I/i }
    code = Array.new(6){arr.sample}.join
    self.code = code
  end

end
