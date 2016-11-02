# ================================================================================
# Part:
# Desc:
# ================================================================================
class Feature
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Constant
  # ==============================================================================
  FEATURE_DEFAULT_DAY_HOW_LONG = 7
  FEATURE_FASTTRACK_DAY = 3
  FEATURE_EXTEND_DAY = 3

  # Dipakai di creative brief biar CH bisa milih mau maksimal berapa hari kontesnya berjalan.
  DURATION_MAX_BRONZE = 7
  DURATION_MAX_SILVER = 10
  DURATION_MAX_GOLD = 14
  DURATION_MAX_PLATINUM = 20


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :icon, type: String
  field :cname, type: String
  field :slug, type: String
  field :price, type: Float
  field :how_long, type: Integer
  field :description, type: String
  field :name_en, type: String
  field :description_en, type: String
  field :active, type: Boolean, default: true

  #                                                                       Relation
  # ==============================================================================
  has_many :contest_features


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
    def as_guarantee
      find_by(cname: "guarantee")
    end

    def as_private
      find_by(cname: "private")
    end

    def as_confidential
      find_by(cname: "confidential")
    end

    def as_fast_tracked
      find_by(cname: "fast tracked")
    end

    def as_extend
      find_by(cname: "extend")
    end

    def get_duration_max(package)
      return self.const_get("DURATION_MAX_"+package)
    end
  end

  #                                                                         Method
  # ==============================================================================
  def feature_name
    (name == "confidential" ? "confidential" : name)
  end

end
