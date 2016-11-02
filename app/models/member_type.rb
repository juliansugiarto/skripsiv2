# ================================================================================
# Part:
# Desc:
# ================================================================================
class MemberType
  include Mongoid::Document
  include Mongoid::Timestamps

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


  #                                                                       Relation
  # ==============================================================================
  has_many :members


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :name


  #                                                                   Class Method
  # ==============================================================================
  class << self
    def designer
      find_by(cname: "designer")
    end

    def contest_holder
      find_by(cname: "contest_holder")
    end
  end

  #                                                                         Method
  # ==============================================================================
end
