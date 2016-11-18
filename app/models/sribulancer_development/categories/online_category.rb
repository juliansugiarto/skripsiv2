class OnlineCategory < CategoryLancer

  include Elasticsearch::Model

  belongs_to :online_group_category

  validates :online_group_category, presence: true

  has_and_belongs_to_many :skills, inverse_of: nil
  has_and_belongs_to_many :promotions

  alias_method :active_record_group_category, :online_group_category

  # display category as string (translated)
  def name_display
    self.name[I18n.locale]
  end

  def name_display_with_budget
    self.name[I18n.locale] + " - [Minimum] #{minimum_budget}"
  end

  # display category seo name as string (translated)
  def name_seo_display
    (self.name_seo[I18n.locale].present?) ? self.name_seo[I18n.locale].parameterize : "-"
  end
  
  def to_s
    cname.tr('_', '-')
  end

  def self.select_list(group_category_id = '*')
    result = Array.new
    self.where(online_group_category_id: group_category_id).active_only.sort_by { |k, v| k[:name][I18n.locale] }.each do |category|
      result << [category.name_display, category.id, {:'data-cname' => category.cname}]
    end
    result
  end

  # if group category is blank return null group category
  # google about Null Object Pattern
  # def group_category
  #   self.active_record_group_category || OnlineGroupCategory.new
  # end

  def self.price_list_minimum_budget
    result = {}
    currencies = Currency.all.to_a
    all.includes(:currency).each do |c|
      result[c.id] = {}
      currencies.each do |currency|
        result[c.id][currency.code] = c.minimum_budget_in_currency(currency).ceil
      end
    end
    result
  end

  def self.work_scope_list
    result = {}
    
    langs = ApplicationController::AVAILABLE_COUNTRY

    all.each do |c|
      result[c.id] = {}
      langs.each do |lang|
        result[c.id][lang] = c.work_scope[lang].present? ? c.work_scope[lang].gsub(/[\r\n\t]/, '<br>').gsub(/<br><br>/, '<br>').gsub("&nbsp;", " ").gsub("&#39;", "'").gsub("\"", "") : nil
      end
    end

    result
    # result.delete_if { |k, v| v.empty? }
  end

  def self.placeholder_titles
    result = {}
    
    langs = ApplicationController::AVAILABLE_COUNTRY

    all.each do |c|
      result[c.id] = {}
      langs.each do |lang|
        result[c.id][lang] = c.placeholder_title[lang].present? ? c.placeholder_title[lang] : nil
      end
    end

    result
  end

  def self.placeholder_descriptions
    result = {}
    
    langs = ApplicationController::AVAILABLE_COUNTRY

    all.each do |c|
      result[c.id] = {}
      langs.each do |lang|
        result[c.id][lang] = c.placeholder_description[lang].present? ? c.placeholder_description[lang] : nil
      end
    end

    result
  end


  def self.required_skills(admin=false)
    result = {}
    
    all.each do |c|
      result[c.id] = {}
      
      c.skill_ids.each do |s|
        skill = SkillLancer.find s
        if admin == true
          result[c.id][skill.id] = "#{skill.name} | #{skill.member_ids.count} orang"
        else
          result[c.id][skill.id] = skill.name
        end
      end
    end

    result
  end

    # convert minimum budget to a given currency
  def minimum_budget_in_currency(to_currency)
    return if to_currency.blank?
    result = 0
    if self.currency == to_currency
      result = self.minimum_budget
    else
      result = self.currency.convert_to_currency(to_currency, self.minimum_budget)
    end
    result
  end

  def minimum_budget_in_currency_display(to_currency)
    "#{to_currency.code} #{number_to_currency(minimum_budget_in_currency(to_currency), unit: '', precision: to_currency.precision_to_use)}"
  end

  def minimum_budget_display
    "#{self.currency.code} #{number_to_currency(self.minimum_budget, unit: '', precision: self.currency.precision_to_use)}"
  end

  # check if given amount is bigger than minimum
  def is_amount_more_than_minimum_budget(currency, amount, obj)
    # In 2015-04-29 we upgrade minimum budget category
    # to prevent error in update and approve, so we have to bypass service that created before
    if obj.created_at.present? and obj.created_at < Time.parse("2015-04-29")
      return true
    else
      minimum_budget_in_currency = minimum_budget_in_currency(currency)
      amount >= minimum_budget_in_currency ? true : false
    end
  end

  # set short ID for SEO, must be number only - better for SEO
  # keep unique across category, group category, and recruitment category
  def set_sid
    self.sid = OnlineCategory.generate_sid if self.sid.blank?
  end

  # generate sid for use in SEO
  # unique across category, group category, and recruitment category
  def self.generate_sid
    sid = rand(10..1000)
    while (self.find_by(sid: sid) or OnlineGroupCategory.find_by(sid: sid)) do
      sid = rand(10..1000)
    end
    sid
  end


  def skill_tokens=(arg)
    # WHAT: Inserting skill.id instead of skill object.
    # REASON: Because mongoid will save all changes even though it doesn't pass our validation.
    # REPRODUCE: 
    # m = Member.last
    # m.skills = [] # member will being save @mongoid-4.0.0
    skill_list = Array.new
    arg ||= ""
    
    arg.split(',').each do |skill_id|
      skill = SkillLancer.find(skill_id)
      skill_list << skill.id if skill.present?
    end
    self.skill_ids = skill_list
  end

  def skill_tokens
    self.skills.collect { |s| "#{s.id}:#{s.name}" }.join(',')
  end

  def as_indexed_json(options={})
    self.as_json(
      only: [:cname, :keywords, :name, :active],
      methods: [:group_active]
    )
  end


  def group_active
    return { active: (self.online_group_category.present?) ? self.online_group_category.active : false }
  end

end
