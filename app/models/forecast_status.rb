# ================================================================================
# Part:
# Desc:
# ================================================================================
class ForecastStatus < Status

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
    def active
      find_by(cname: "active")
    end

    def not_active
      find_by(cname: "not_active")
    end
  end

  #                                                                         Method
  # ==============================================================================

end