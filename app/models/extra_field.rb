# ================================================================================
# Part:
# Desc:
# ================================================================================
class ExtraField
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :description, type: String
  field :help, type: String
  field :active, type: Boolean, default: false
  field :optional, type: Boolean, default: true
  field :rank, type: Integer, default: 0
  field :name_en, type: String
  field :description_en, type: String


  #                                                                       Relation
  # ==============================================================================
  belongs_to :extra_field_type
  belongs_to :category
  has_many :extra_field_values


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :name
  validates_numericality_of :rank

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================

end
