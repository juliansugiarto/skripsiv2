# ================================================================================
# Part:
# Desc: "email", "meeting", "phone", "whatsapp", "livechat"
# ================================================================================
class FollowUpSource
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
    def email
      find_by(cname: "email")
    end

    def phone
      find_by(cname: "phone")
    end

    def whatsapp
      find_by(cname: "whatsapp")
    end

    def meeting
      find_by(cname: "meeting")
    end

    def livechat
      find_by(cname: "livechat")
    end
  end

  #                                                                         Method
  # ==============================================================================

end
