# ================================================================================
# Part:
# Desc:
# ================================================================================
class WinnerStatus < Status

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================


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
    def pending
      find_by(cname: "pending")
    end

    def open
      find_by(cname: "open")
    end

    def closed
      find_by(cname: "closed")
    end
  end

  #                                                                         Method
  # ==============================================================================

end
