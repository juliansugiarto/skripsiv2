# ================================================================================
# Part:
# Desc:
# ================================================================================
class Detail
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_save do
    set_default_attributes
  end

  #                                                                          Field
  # ==============================================================================
  field :colors, type: Array
  field :company_info

  #                                                                       Relation
  # ==============================================================================
  # Consider to change this relationship
  belongs_to :contest
  has_many :detail_logo_types


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================
  def logo_types
    LogoType.where(:id.in => self.detail_logo_types.map(&:logo_type_id))
  end

  #                                                                     Validation
  # ==============================================================================

  validates :colors, :length => {:maximum => 3, :message => :custom_length}

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def set_default_attributes
    self.colors = [] if self.colors.blank?
  end


end
