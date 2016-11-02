# ================================================================================
# Part:
# Desc:
# ================================================================================
class Service
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Constant
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :icon, type: String
  field :cname, type: String
  field :slug, type: String
  field :description, type: String
  field :active, type: Boolean, default: true

  #                                                                       Relation
  # ==============================================================================
  has_many :contest_services


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :name
  validates_presence_of :cname
  validates_presence_of :slug

  #                                                                   Class Method
  # ==============================================================================
  class << self

    def need_patent_registration
      find_by(cname: "need_patent_registration")
    end

    def need_outsource_clothing_production
      find_by(cname: "need_outsource_clothing_production")
    end

    def need_outsource_video_production
      find_by(cname: "need_outsource_video_production")
    end

    def need_outsource_web_development
      find_by(cname: "need_outsource_web_development")
    end

    def need_outsource_online_marketing
      find_by(cname: "need_outsource_online_marketing")
    end

    def need_outsource_printing
      find_by(cname: "need_outsource_printing")
    end

    def need_outsource_production
      find_by(cname: "need_outsource_production")
    end

    def need_outsource_web_hosting
      find_by(cname: "need_outsource_web_hosting")
    end

    def bulk_order
      find_by(cname: "bulk_order")
    end

  end

  #                                                                         Method
  # ==============================================================================

end
