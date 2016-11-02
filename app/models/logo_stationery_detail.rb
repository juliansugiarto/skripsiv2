# ================================================================================
# Part:
# Desc:
# ================================================================================
class LogoStationeryDetail < Detail

  #                                                                       Constant
  # ==============================================================================
  LOGO_TYPES_MINIMUM = 1
  LOGO_TYPES_MAXIMUM = 4

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name_in_logo, type: String
  field :info_in_stationery, type: String


  #                                                                       Relation
  # ==============================================================================
  # Please change this relationships
  # Use MTI instead
  # has_and_belongs_to_many :logo_types


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates :name_in_logo, presence: true
  validates :info_in_stationery, presence: true


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================


end
