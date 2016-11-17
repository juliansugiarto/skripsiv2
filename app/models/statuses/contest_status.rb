# ================================================================================
# Part:
# Desc:
# ================================================================================
class ContestStatus < Status

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

    def draft
      find_by(cname: "draft")
    end

    def not_active
      find_by(cname: "not_active")
    end

    def open
      find_by(cname: "open")
    end

    def winner_pending
      find_by(cname: "winner_pending")
    end

    def file_transfer
      find_by(cname: "file_transfer")
    end

    def closed
      find_by(cname: "closed")
    end

    def no_winner
      find_by(cname: "no_winner")
    end

    def refund
      find_by(cname: "refund")
    end

  end

  #                                                                         Method
  # ==============================================================================

end
