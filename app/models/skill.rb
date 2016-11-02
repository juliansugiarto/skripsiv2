# ================================================================================
# Part:
# Desc:
# ================================================================================
class Skill
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_save :parameterize_attributes


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :slug, type: String



  #                                                                       Relation
  # ==============================================================================
  belongs_to :category
  has_many :member_skills

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  private
  def parameterize_attributes
    self.slug = self.name.parameterize
  end

end
