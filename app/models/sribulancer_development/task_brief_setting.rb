class TaskBriefSetting
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'task_brief_settings'
  # Briefs list based on partial names, will be used to render partial, brief name => model name
  TASK_BRIEFS_LIST = {"cleaning_service_1" => "CleaningServiceBrief",
    "handyman_plumber_contractor_1" => "HandymanPlumberContractorBrief"}

  field :model_name
  field :brief_name
  field :active, type: Boolean, default: true

  has_many :offline_categories


  def category_tokens=(arg)
    category_list = Array.new
    arg ||= ""

    arg.split(',').each do |category_id|
      category = OfflineCategory.find(category_id)
      category_list << category.id if category.present?
    end
    self.offline_category_ids = category_list
  end

  def category_tokens
    self.offline_categories.collect { |s| "#{s.id}:#{s.cname}" }.join(',')
  end

  # Hanya display category dengan bootstrap label
  # Lain kegunaan nya dengan job_helper#show_required_categorys
  def categorys_display_label
    ret = ''

    ret = "<span class='title-required-categorys'>" + I18n.t('jobs.new.label.required_categorys') + ":</span> " if self.offline_categories.any?
    self.offline_categories.each do |s|
      ret += "<span class='label label-default label-type-1 mr-5'>#{s.name[:en]}</span>"
    end

    return ret
  end

end
