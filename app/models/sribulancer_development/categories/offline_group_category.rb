class OfflineGroupCategory < GroupCategoryLancer

  has_many :service_provider_member
  has_many :offline_categories

  def self.optgroup
    result = Array.new
    self.active_only.all.each do |online_group_category|
      result << [online_group_category.name_display, OfflineCategory.select_list(online_group_category.id)]
    end
    result
  end
end
