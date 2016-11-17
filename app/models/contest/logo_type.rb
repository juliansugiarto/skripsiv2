# ================================================================================
# Part:
# Desc:
# ================================================================================
class LogoType

  include Mongoid::Document
  include Mongoid::Timestamps


  #                                                                       Constant
  # ==============================================================================
  ABSTRACT = 'abstract'
  SYMBOL = 'symbol'
  TYPOGRAPHY = 'typography'
  ILLUSTRATION = 'illustration'
  CORPORATE = 'corporate'
  FUN = 'fun'
  WEB20 = 'web20'
  INITIAL = 'initial'


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :cname, type: String
  field :slug, type: String
  field :description, type: String
  field :picture_file_name, type: String
  field :order, type: Integer


  #                                                                       Relation
  # ==============================================================================


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

end
