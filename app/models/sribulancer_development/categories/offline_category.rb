class OfflineCategory < CategoryLancer
  
  include Elasticsearch::Model

  belongs_to :offline_group_category
  belongs_to :task_brief_setting

  validates :offline_group_category, presence: true

  def self.select_list(group_category_id)
    result = Array.new
    self.where(offline_group_category_id: group_category_id).active_only.sort_by { |k, v| k[:name][I18n.locale] }.each do |category|
      result << [category.name_display, category.id, {:'data-cname' => category.cname}]
    end
    result
  end

  # set short ID for SEO, must be number only - better for SEO
  # keep unique across category, group category, and recruitment category
  def set_sid
    self.sid = OfflineCategory.generate_sid if self.sid.blank?
  end

  def name_seo_display
    self.name_seo[I18n.locale].parameterize
  end

  # generate sid for use in SEO
  # unique across category, group category, and recruitment category
  def self.generate_sid
    sid = rand(10..1000)
    while (self.find_by(sid: sid) or OfflineGroupCategory.find_by(sid: sid)) do
      sid = rand(10..1000)
    end
    sid
  end

  def name_display
    self.name[I18n.locale]
  end

end
