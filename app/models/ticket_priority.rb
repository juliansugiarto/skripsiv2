# ================================================================================
# Part:
# Desc: cold, warm (default), hot
# ================================================================================
class TicketPriority
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
  field :description, type: String

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
  class << self
    def cold
      find_by(cname: "cold")
    end

    def warm
      find_by(cname: "warm")
    end

    def hot
      find_by(cname: "hot")
    end
  end

  #                                                                         Method
  # ==============================================================================

end
