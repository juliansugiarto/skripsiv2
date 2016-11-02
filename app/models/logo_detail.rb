# ================================================================================
# Part:
# Desc:
# ================================================================================
class LogoDetail < Detail

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
  # validate :logo_types_count


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  # def logo_types_count
  #   if self.logo_types.size < LOGO_TYPES_MINIMUM or self.logo_types.size > LOGO_TYPES_MAXIMUM
  #     errors.add(:logo_types, I18n.t('contests.logo_detail.validation.logo_types_count', :minimum => LOGO_TYPES_MINIMUM, :maximum => LOGO_TYPES_MAXIMUM))
  #   end
  # end

end
