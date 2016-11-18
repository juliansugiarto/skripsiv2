class OnlineGroupCategory < GroupCategoryLancer
  # display category as string (translated)

  has_many :skills

  has_many :online_categories
  has_many :member_preferences

  has_many :portfolio

  def self.optgroup
    result = Array.new
    self.active_only.all.each do |online_group_category|
      result << [online_group_category.name_display, OnlineCategory.select_list(online_group_category.id)]
    end
    result
  end

  # get all category ids of this group category
  def online_category_ids
    self.online_categories.collect(&:_id)
  end

end
