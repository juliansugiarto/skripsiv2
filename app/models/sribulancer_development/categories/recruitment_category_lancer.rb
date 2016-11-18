# represent category for recruitment
class RecruitmentCategoryLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'recruitment_categories'
  # include this module to provide calling link_to method inside model
  include ActionView::Helpers

  field :cname
  field :name, type: Hash, default: {}
  field :name_seo, type: Hash, default: {}

  # short ID to be used in URL for seo
  field :sid, type: Integer

  field :active, type: Boolean, default: true

  validates :cname, presence: true, :uniqueness => true

  scope :cname_asc, -> {asc(:cname).where(active: true)}

  before_create :set_sid

  # display category as string (translated)
  def name_display
    self.name[I18n.locale]
  end

    # display category seo name as string (translated)
  def name_seo_display
    self.name_seo[I18n.locale].parameterize
  end

  def to_s
    cname.tr('_', '-')
  end

  def self.select_list
    result = Array.new
    RecruitmentCategory.cname_asc.each do |category|
      result << [category.name_display]
    end
    result
  end

  # set short ID for SEO, must be number only - better for SEO
  # keep unique across category, group category, and recruitment category
  def set_sid
    self.sid = OnlineCategory.generate_sid if self.sid.blank?
  end

end
