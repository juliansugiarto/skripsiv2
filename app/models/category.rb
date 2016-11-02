# ================================================================================
# Part:
# Desc:
# ================================================================================
class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================
  CATEGORY_LOCALES  = {'en' => 'english', 'id' => 'indonesia'}
  CATEGORY_TYPES    = ['one', 'one-b']

  CATEGORY_NAMES_VALUES = ["Logo Design",         # 0
                 "Stationery Design",             # 1
                 "Logo & Stationery Designs",     # 2
                 "Simple Web Design",             # 3   one-b
                 "Flyer / Brochure Design",       # 4
                 "Invitation Design",             # 5
                 "T-Shirt Design",                # 6
                 "Banner Ads",                    # 7
                 "Calendar Design",               # 8   one-b
                 "Packaging Design",              # 9
                 "Product Design",                # 10  one-b
                 "Naming/Tagline",                # 11
                 "Mascot",                        # 12
                 "Poster Design",                 # 13
                 "Interior",                      # 14  one-b
                 "Other",                         # 15
                 "Label Design",                  # 16
                 "Infographic Theme"]             # 17

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

  # Yang name di atas tetap inggris, biar tidak mempengaruhi push ke kissmetrics & proses yang sudah ada
  field :name_id, type: String
  field :active, type: Boolean, default: true
  field :rank, type: Integer, default: 0
  field :information, type: String

  field :additional_information, type: String
  field :additional_information_id, type: String

  field :additional_information_2, type: String
  field :additional_information_2_id, type: String

  field :cat_type, type: String
  field :category_group , type: String        # Untuk keperluan step 1 buat kontes
  field :category_group_order, type: Integer   # Supaya bisa diubah posisi ordernya kategori
  field :category_group_detail_order, type: Integer   # Supaya bisa diubah posisi ordernya item di dalam kategori


  #                                                                       Relation
  # ==============================================================================
  has_many :contests
  has_many :packages
  has_many :leads

  belongs_to :group_category

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :name
  validates_presence_of :rank
  validates_numericality_of :rank

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================

end
