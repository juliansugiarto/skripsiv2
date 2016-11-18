# represent category parent for sub category
class GroupCategoryLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  
  store_in database: 'sribulancer_development', collection: 'group_categories'
  before_create :set_sid

  field :cname
  field :name, type: Hash, default: {}
  field :name_seo, type: Hash, default: {}

  # short ID to be used in URL for seo
  field :sid, type: Integer

  field :active, type: Boolean, default: true

  validates :cname, presence: true, :uniqueness => true
   
  scope :active_only, -> {where(active: true)}
  scope :cname_asc, -> {asc(:cname).where(active: true)}

  PRIORITY_LIST = ['website_and_development', 'writing_and_translation', 'design_and_multimedia', 'data_entry', 'business_and_online_marketing', 'mobile_apps_development', 'translation']

  def name_display
    self.name[I18n.locale]
  end

  # display category seo name as string (translated)
  def name_seo_display
    self.name_seo[I18n.locale].parameterize
  end

  def self.select_list(is_vpa_included = false, unscoped = false)
    result = Array.new
    group_categories = (unscoped==false) ? self.active_only : self.unscoped # Supaya di 4dm1n/online_categories -> Filter GCategory muncul semua

    group_categories.sort_by { |k, v| k[:name][I18n.locale] }.each do |group_category|
      result << [group_category.name_display, group_category.id]
    end
    result
  end

  def self.select_list_by_priority
    result = Array.new

    # collect the priorities ones first
    PRIORITY_LIST.each do |pl|
      gc = GroupCategory.find_by(cname: pl)
      result << [gc.name_display, gc.id]
    end

    # append the rest
    self.active_only.where(:cname.nin => PRIORITY_LIST).sort_by { |k, v| k[:name][I18n.locale] }.each do |group_category|
      result << [group_category.name_display, group_category.id]
    end
    result
  end

   # set short ID for SEO, must be number only - better for SEO
  # keep unique across category, group category, and recruitment category
  def set_sid
    self.sid = OnlineCategory.generate_sid if self.sid.blank?
  end
end
