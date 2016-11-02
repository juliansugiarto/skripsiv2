# ================================================================================
# Part:
# Desc:
# ================================================================================
class WinnerType
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


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
  has_many :winners


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
    def as_winner
      WinnerType.find_by(cname: "winner")
    end
    def as_runner_up
      WinnerType.find_by(cname: "runner_up")
    end
  end

  #                                                                         Method
  # ==============================================================================


  # ==============================================================================
  # PLACE ALL DELETED, MIGRATED, RENAMED OBJECT HERE
  # ==============================================================================

end
