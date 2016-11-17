# ================================================================================
# Part:
# Desc:
# ================================================================================
class WebsiteDetail < Detail

  #                                                                       Constant
  # ==============================================================================
  LOGO_TYPES_MINIMUM = 1
  LOGO_TYPES_MAXIMUM = 4
  DESIGN_REFERENCES_MAXIMUM = 3


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :domain_name, type: String
  field :existing_website, type: String
  field :total_page, type: Integer
  field :page_descriptions, type: Array
  field :design_references, type: Array


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
  # validate :validate_total_page_descriptions


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  # def validate_total_page_descriptions
  #   page_descriptions = self.page_descriptions.reject { |pd| pd.empty? }
  #   if self.total_page != page_descriptions.size
  #     errors.add(:page_descriptions, I18n.t('contests.creative_v2.label.website_all_page_descriptions_must_be_given'))
  #   end
  # end

end
